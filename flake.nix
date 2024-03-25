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
          # Pull in all univesrally required sources.
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
            installPhase = "cp -r mpy-cross/build $out";
          };
        in {
          esp32c3 = import ./ports/esp32/generic-c3.nix {
            inherit pkgs esp-dev mpy-cross micropython-src berkeley-db-1_xx-src;
          };
      });
    };
}
