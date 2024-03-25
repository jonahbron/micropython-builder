{
  description = "Example building flake";
  inputs.micropython-builder.url = "github:jonahbron/micropython-builder";
  outputs = { self, micropython-builder }: {
    packages.x86_64-linux.default = micropython-builder.lib.x86_64-linux.mkFirmwareDerivation {
      port = "esp32";
      board = "ESP32_GENERIC_C3";
      sha256 = "sha256-pgp40inNjT1cCX2S8/EjVTTytaK7zz8+x1sT7nWLHT0=";
      # freezeManifest = ./manifest.py;
      # userCModules = ./derivation-containing-cmake
    };
  };
}
