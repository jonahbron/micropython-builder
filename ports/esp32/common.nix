{pkgs, ...}@inputs:
  let
    common = import ./../common.nix inputs;
  in common // {
    frozenManifest = frozenManifestText: pkgs.writeText "manifest.py" ''
      include("${common.micropython-src}/ports/esp32/boards/manifest.py")
      ${frozenManifestText}
    '';
  }
