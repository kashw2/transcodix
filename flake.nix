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
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in
    {
      nixosModules.default = self.nixosModules.transcodix;
      nixosModules.transcodix.imports = [ ./module.nix ];

      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = import ./package.nix {
            inherit pkgs;
            watchDirectory = "/tmp/transcodix/watch";
            watchExtension = "mkv";
            outputDirectory = "/tmp/transcodix/output";
            transcodingPackage = "handbrake";
          };
        }
      );
    };
}
