{
  description = "Example building flake";
  inputs.micropython-builder.url = "github:jonahbron/micropython-builder";
  outputs = { self, micropython-builder }: {
    packages.x86_64-linux.default = micropython-builder.lib.x86_64-linux.esp32c3.buildMicroPythonFirmware {
      sha256 = "sha256-pgp40inNjT1cCX2S8/EjVTTytaK7zz8+x1sT7nWLHT0=";
    };

    # This approach is for the purpose of the example, but it's not ideal
    # because the dependency version cannot be frozen. It's recommended to
    # instead call freeze() on a derivation pulled in with fetchFromGitHub.
    packages.x86_64-linux.frozenManifest = micropython-builder.lib.x86_64-linux.esp32c3.buildMicroPythonFirmware {
      sha256 = "sha256-XTQq1dwpj/lDAxzH/cQnbRF1zljvCMRvaXd9He+YJNY=";
      frozenManifestText = ''
        require('aiohttp')
      '';
    };

    # Point userCModules to a derivation containing all of the C code that the
    # firmware needs to have.  It must have a `micropython.cmake` file at the
    # root that includes everything.
    packages.x86_64-linux.userCModules = micropython-builder.lib.x86_64-linux.esp32c3.buildMicroPythonFirmware {
      userCModules = ./user_c_modules;
      sha256 = "sha256-pgp40inNjT1cCX2S8/EjVTTytaK7zz8+x1sT7nWLHT0=";
    };

    # PatchPhase current directory is in the build environment, in the root of
    # the micropython source.  Here arbitrary scripts can be run to mutate the
    # source or libraries before build.
    packages.x86_64-linux.patchPhase = micropython-builder.lib.x86_64-linux.esp32c3.buildMicroPythonFirmware {
      patchPhase = ''
        echo 'Hello world' > text.txt
      '';
      sha256 = "sha256-pgp40inNjT1cCX2S8/EjVTTytaK7zz8+x1sT7nWLHT0=";
    };

    # Derivation's output contains an executable that can be run with
    # `nix run .#flash`
    packages.x86_64-linux.flash = micropython-builder.lib.x86_64-linux.esp32c3.flashMicroPythonFirmware {
      sha256 = "sha256-pgp40inNjT1cCX2S8/EjVTTytaK7zz8+x1sT7nWLHT0=";
    };
  };
}
