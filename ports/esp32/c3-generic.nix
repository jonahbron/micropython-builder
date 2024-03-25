{pkgs, esp-dev, ...}@inputs:
let
  common = import ./common.nix inputs;
  # TODO extract non-C3-specific expressions into ../
  buildMicroPythonFirmware = {
    frozenManifestText ? "",
    userCModules ? pkgs.writeTextDir "micropython.cmake" "",
    patchPhase ? "",
    # TODO Until this issue is resolved, output must be fixed.
    # https://github.com/espressif/idf-component-manager/issues/54
    # Might need to keep it as an option even after so that manifest
    # `require()` can be used.
    sha256 ? "",
  }:
    let
    in pkgs.stdenv.mkDerivation {
      name = "esp32_generic_c3";
      src = common.micropython-src;
      nativeBuildInputs = [esp-dev.esp-idf-esp32c3];
      phases = ["unpackPhase" "patchPhase" "buildPhase" "installPhase"];
      patchPhase = ''
        ${common.patchPhase {inherit userCModules;}}

        # Instead of recursively loading all submodules in the MicroPython
        # source, each port should only pull in the specific ones it needs.
        rmdir lib/berkeley-db-1.xx
        ln -s ${common.berkeley-db-1_xx-src} lib/berkeley-db-1.xx

        # ESP-IDF will analyze its own source repository at run-time, which
        # will cause complaits by Git because of its position in store and
        # being owned by Root.  Mark it as safe to avoid those problems.
        git config --global --add safe.directory \
          '${esp-dev.esp-idf-esp32c3}'

        # Additional patches specified by caller.
        ${patchPhase}
      '';

      buildPhase = common.buildPhase {
        board = "ESP32_GENERIC_C3";
        inherit frozenManifestText;
        userCModules = "$(realpath lib/user_c_modules/micropython.cmake)";
      };

      installPhase = ''
        # TODO provide multiple outputs with different built parts
        cp ports/esp32/build-ESP32_GENERIC_C3/firmware.bin $out
      '';
      outputHash = sha256;
      outputHashAlgo = "sha256";
      outputHashMode = "recursive";
    };

in {
  inherit buildMicroPythonFirmware;

  flashMicroPythonFirmware = common.flashMicroPythonFirmware {
    inherit buildMicroPythonFirmware;
    chip = "esp32c3";
  };
}
