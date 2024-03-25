# MicroPython Builder

This is a flake that knows how to build and flash MicroPython.  It can either
be invoked directly to build a basic firmware, or it can be used as an input
flake and be used as a tool to build a custom firmware.

```bash
nix run github:jonahbron/micropython-builder#flash-esp32c3-generic
```

> [!WARNING]
> Because a network connection is currently _required_ to build firmware for
> ESP32 devices, flashing directly from the terminal will only work on non-x86_64
> systems.  You must create your own flake with your own sha256.
>
> [Builds fail without Internet access (IDFGH-12120) (PACMAN-808) #54][esp-idf]

See [examples](./examples) directory or a [real project][usage] for how to use
this builder in your own flake. The examples are also a flake and can be run
directly.

```bash
nix build ./examples#
```

## Currently Supported Ports/Boards

> [!NOTE]
> Contributions of other MicroPython ports/boards are extremely welcome!

- [x] [ESP32][esp32]
  - [x] [ESP32_GENERIC_C3][esp32c3-generic]

## TODO
- [x] Flake package that can be run like `nix build .#esp32c3-generic`
  - [x] Default output is firmware.bin
  - [ ] Other output portions can be accessed too `nix build .#esp32GenericC3.bootloader`
- [x] Flake package that can be run like `nix run .#flash-esp32-generic`
- [x] Flake library that can be called like `buildMicroPythonFirmware`
  - [x] Allows specifying the port/board
  - [x] Accepts arguments pointing to manifest.py
  - [x] Accepts arguments pointing to user_c_modules
  - [x] Allow patch phase script
  - [ ] Allow overriding the micropython source
  - [ ] Allow overriding the micropython-lib source
- [x] Flake library that can be called like `flashMicroPythonFirmware`
- [x] Make interface more ergonomic, require less knowledge
- [ ] Make fixed-output derivations optional
- [ ] Factor out common ESP32 expressions
- [ ] Add nix formatter
- [ ] Flake template
- [ ] GitHub Action that attempts to regularly update dependencies
- [ ] Contribute into nixpkgs?

[esp-idf]: https://github.com/espressif/idf-component-manager/issues/54
[usage]: https://git.sr.ht/~jonahbron/doorbell/tree/17a3b500eadaea10a203baa3f078df4f40ce0f45/item/firmware.nix
[esp32]: https://github.com/micropython/micropython/tree/master/ports/esp32
[esp32c3-generic]: https://github.com/micropython/micropython/tree/master/ports/esp32/boards/ESP32_GENERIC_C3
