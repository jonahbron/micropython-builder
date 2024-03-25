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
      lib = forAllSystems (pkgs: {
        esp32c3-generic = import ./ports/esp32/c3-generic.nix {
          inherit pkgs;
          esp-dev = esp-dev.packages.${pkgs.system};
        };
      });

      packages = forAllSystems (pkgs: {
        esp32c3-generic = self.lib.${pkgs.system}.esp32c3-generic.buildMicroPythonFirmware {
          # Built on x86_64-linux
          sha256 = "sha256-pgp40inNjT1cCX2S8/EjVTTytaK7zz8+x1sT7nWLHT0=";
        };
        flash-esp32c3-generic = self.lib.${pkgs.system}.esp32c3-generic.flashMicroPythonFirmware {
          # Built on x86_64-linux
          sha256 = "sha256-pgp40inNjT1cCX2S8/EjVTTytaK7zz8+x1sT7nWLHT0=";
        };
      });
    };
}
