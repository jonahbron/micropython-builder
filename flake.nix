{
  description = "A flake that knows how to build MicroPython";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    esp-dev.url = "github:mirrexagon/nixpkgs-esp-dev?ref=master";
  };

  outputs = { self, nixpkgs, esp-dev }@attrs:
    let
      forAllSystems = function:
        nixpkgs.lib.genAttrs [
          "x86_64-linux"
          "aarch64-linux"
        ] (system: function (import nixpkgs { inherit system; }));
    in {
      lib = forAllSystems (pkgs:
        let
          berkeley-db-1_xx-src = pkgs.fetchFromGitHub {
            owner = "pfalcon";
            repo = "berkeley-db-1.xx";
            rev = "85373b548f1fb0119a463582570b44189dfb09ae";
            sha256 = "sha256-HyQXMy5mruTQHL4LcACfLxJGhu6jpOSQbnbS/A/aGE0=";
          };
          micropython-src = pkgs.fetchFromGitHub {
            owner = "micropython";
            repo = "micropython";
            rev = "35b2edfc240050fc5310093db29927f6226c3157";
            sha256 = "sha256-xzyxmbSnCuoFGNYe+Ui+YdVlgE52yOeRwmghR8oulfM=";
          };
          micropython-lib-src = pkgs.fetchFromGitHub {
            owner = "micropython";
            repo = "micropython-lib";
            rev = "661efa48f091f4279098c99cfb4e942e2b8d1b51";
            sha256 = "sha256-WN9jv2pwxi00DP8kpqDJBmzVRjo/PuaFeu0zevve6B4=";
          };

          # Build mpy-cross separately to avoid rebuilding it as the firmware iterates.
          mpy-cross = pkgs.stdenv.mkDerivation {
            name = "mpy-cross";
            buildInputs = [
              # Depending on nixpkgs-esp-dev to ensure same Python version.
              esp-dev.packages.${pkgs.system}.esp-idf-esp32c3
            ];
            src = micropython-src;
            phases = ["unpackPhase" "buildPhase" "installPhase"];
            buildPhase = "make V=1 -C mpy-cross";
            installPhase = ''
              cp -r mpy-cross/build $out
            '';
          };
          boardMkDerivationOptions = {
            esp32.ESP32_GENERIC_C3 = opts: args:
            let
              frozenManifest = pkgs.writeText "manifest.py" ''
                include("${micropython-src}/ports/esp32/boards/manifest.py")
                ${args.frozenManifestText}
              '';
            in opts // {
              name = "esp32_generic_c3";
              nativeBuildInputs = [esp-dev.packages.${pkgs.system}.esp-idf-esp32c3];
              patchPhase = ''
                ${opts.patchPhase}

                rmdir lib/berkeley-db-1.xx
                ln -s ${berkeley-db-1_xx-src} lib/berkeley-db-1.xx # Required by stdlib

                git config --global --add safe.directory \
                  '${esp-dev.packages.${pkgs.system}.esp-idf-esp32c3}'
              '';

              buildPhase = ''
                ${opts.buildPhase}

                # Build the MicroPython firmware.
                # TODO split the various parts of the firmware into separate derivations
                # then combine, to optimize re-compilation depending on what is updated.
                make V=1 -C ports/esp32 BOARD=ESP32_GENERIC_C3 \
                  FROZEN_MANIFEST="${frozenManifest}"
              '';

              installPhase = ''
                cp ports/esp32/build-ESP32_GENERIC_C3/firmware.bin $out
              '';
            };
          };
        in {
          mkFirmwareDerivation = {
            port,
            board,
            frozenManifestText ? "",
            # Until this issue is resolved, output must be fixed.
            # https://github.com/espressif/idf-component-manager/issues/54
            sha256 ? "",
          }@opts:
            let
            in
              pkgs.stdenv.mkDerivation (boardMkDerivationOptions.${port}.${board} {
                src = micropython-src;
                phases = ["unpackPhase" "patchPhase" "buildPhase" "installPhase"];
                patchPhase = ''
                  rmdir lib/micropython-lib
                  ln -s ${micropython-lib-src} lib/micropython-lib
                  ln -s ${mpy-cross} mpy-cross/build
                  export GIT_CONFIG_GLOBAL=$(realpath .gitconfig)
                '';

                buildPhase = ''
                  export HOME=$(pwd)
                '';
                outputHash = sha256;
                outputHashAlgo = "sha256";
                outputHashMode = "recursive";
              } opts);
      });
    };
}
