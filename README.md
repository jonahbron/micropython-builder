# MicroPython Builder

This is a flake that knows how to build MicroPython.  It can either be invoked
directly to build a basic firmware, or it can be used as an input flake and
be used as a tool to build a custom firmware. 

```bash
nix run github:jonahbron/micropython-builder#flash-esp32GenericC3
```

See [`examples/`](./examples) for examples of usage as an input to another
flake.

## Currently Supported Ports/Boards

- [ ] [ESP32](https://github.com/micropython/micropython/tree/master/ports/esp32) 
  - [ ] [ESP32_GENERIC_C3](https://github.com/micropython/micropython/tree/master/ports/esp32/boards/ESP32_GENERIC_C3)

## TODO
- [ ] Flake package that can be run like `nix build .#esp32GenericC3`
  - [ ] Default output is firmware.bin
  - [ ] Other output portions can be accessed too `nix build .#esp32GenericC3.bootloader`
- [ ] Flake package that can be run like `nix run .#flash-esp32GenericC3`
- [ ] Top-level Flake output callable named like mkFirmwareDerivation
  - [ ] Allows specifying the port/board
  - [ ] Accepts arguments pointing to manifest.py
  - [ ] Accepts arguments pointing to user_c_modules
  - [ ] Allow patch phase script
  - [ ] Allow overriding the micropython source
  - [ ] Allow overriding the micropython-lib source
- [ ] Contribute into nixpkgs?

