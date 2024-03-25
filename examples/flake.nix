{
  description = "Example building flake";
  inputs.micropython-builder.url = "";
  outputs = { self, micropython-builder }: {
    packages.x86_64-linux.default = micropython-builder.packages.x86_64-linux.mkFirmwareDerivation {
      port = "esp32";
      board = "ESP32_GENERIC_C3";
      freezeManifest = ./manifest.py;
      userCModules = ./derivation-containing-cmake
    };
  };
}
