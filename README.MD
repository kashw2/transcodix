# Transcodix

Transcodix is a NixOS Module that allows you to turn your machine into a media transcoding server.

## Installation

flake.nix

```nix
inputs.transcodix.url = "github:kashw2/transcodix";
```

configuration.nix

```nix
services.transcodix = {
    enable = true;
    watchDirectory = "/some/absolute/directory";
    watchExtension = "mkv";
    outputDirectory = "/some/absolute/directory/out";
};
```