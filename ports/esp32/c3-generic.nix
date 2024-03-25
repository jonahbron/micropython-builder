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
  }@args:
    let
    in pkgs.stdenv.mkDerivation {
      name = "esp32_generic_c3";
      src = common.micropython-src;
      nativeBuildInputs = [esp-dev.esp-idf-esp32c3];
      phases = ["unpackPhase" "patchPhase" "buildPhase" "installPhase"];
      patchPhase = ''
        rmdir lib/micropython-lib
        ln -s ${common.micropython-lib-src} lib/micropython-lib
        ln -s ${common.mpy-cross} mpy-cross/build
        export GIT_CONFIG_GLOBAL=$(realpath .gitconfig)

        rmdir lib/berkeley-db-1.xx
        ln -s ${common.berkeley-db-1_xx-src} lib/berkeley-db-1.xx # Required by stdlib

        # Included C modules must be copied in.  Referencing them
        # directly in the Store (or even symlinking them in) will leave
        # stray Store paths in the output binary, which is illegal for
        # fixed-output derivations.
        cp -r ${userCModules} lib/user_c_modules

        git config --global --add safe.directory \
          '${esp-dev.esp-idf-esp32c3}'

        # Additional patches specified by caller.
        ${patchPhase}
      '';

      buildPhase = ''
        export HOME=$(pwd)

        # Build the MicroPython firmware.
        # TODO split the various parts of the firmware into separate derivations
        # then combine, to optimize re-compilation depending on what is updated.
        make V=1 -C ports/esp32 \
          BOARD=ESP32_GENERIC_C3 \
          FROZEN_MANIFEST="${common.frozenManifest frozenManifestText}" \
          USER_C_MODULES="$(realpath lib/user_c_modules/micropython.cmake)"
      '';

      installPhase = ''
        # TODO provide multiple outputs with different built parts
        cp ports/esp32/build-ESP32_GENERIC_C3/firmware.bin $out
      '';
      outputHash = sha256;
      outputHashAlgo = "sha256";
      outputHashMode = "recursive";
    };

  flashMicroPythonFirmware = firmwareOptions:
    pkgs.writeShellScriptBin "flash-micropython" ''
      ${pkgs.esptool}/bin/esptool.py \
        --chip esp32c3 \
        # TODO accept as argument somehow
        --port /dev/ttyACM0 \
        --baud 921600 \
        --before default_reset \
        --after hard_reset \
        --no-stub write_flash \
        --flash_mode dio \
        --flash_freq 80m \
        0x0 \
        ${buildMicroPythonFirmware firmwareOptions}
    '';
in {
  inherit buildMicroPythonFirmware flashMicroPythonFirmware;
}
