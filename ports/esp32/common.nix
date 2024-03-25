{pkgs, ...}@inputs:
  let
    common = import ./../common.nix inputs;

    frozenManifest = frozenManifestText: pkgs.writeText "manifest.py" ''
      include("${common.micropython-src}/ports/esp32/boards/manifest.py")
      ${frozenManifestText}
    '';
  in common // {

    patchPhase = {userCModules}: ''
      rmdir lib/micropython-lib
      ln -s ${common.micropython-lib-src} lib/micropython-lib
      ln -s ${common.mpy-cross} mpy-cross/build

      # Set up a writable "global" config file for setting the safe directory.
      export GIT_CONFIG_GLOBAL=$(realpath .gitconfig)

      # Included C modules must be copied in.  Referencing them
      # directly in the Store (or even symlinking them in) will leave
      # stray Store paths in the output binary, which is illegal for
      # fixed-output derivations.
      cp -r ${userCModules} lib/user_c_modules
    '';

    buildPhase = {board, frozenManifestText, userCModules}:
      let
        frozenManifest = pkgs.writeText "manifest.py" ''
          include("${common.micropython-src}/ports/esp32/boards/manifest.py")
          ${frozenManifestText}
        '';
      in ''
        export HOME=$(pwd)

        # Build the MicroPython firmware.
        # TODO split the various parts of the firmware into separate derivations
        # then combine, to optimize re-compilation depending on what is updated.
        make V=1 -C ports/esp32 \
          BOARD=${board} \
          FROZEN_MANIFEST="${frozenManifest}" \
          USER_C_MODULES="${userCModules}"
      '';
    flashMicroPythonFirmware = {chip, buildMicroPythonFirmware}: firmwareOptions:
      pkgs.writeShellScriptBin "flash-micropython" ''
        ${pkgs.esptool}/bin/esptool.py \
          --chip ${chip} \
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
  }
