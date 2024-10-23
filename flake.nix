{
  description = "Transcodix - Transcode Service";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs =
    {
      self,
      nixpkgs,
    }:
    {
      nixosModules.default = self.nixosModule.transcodix;
      nixosModules.transcodix.imports = [ ./module/module.nix ];
    };
}
