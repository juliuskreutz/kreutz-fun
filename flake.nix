{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mirrorfour-api = {
      url = "git+file:///home/julius/Projects/rust/mirrorfour-api";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs: {
    nixosConfigurations.kreutz-fun = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        { networking.hostName = "kreutz-fun"; }
        inputs.disko.nixosModules.disko
        ./disk-config.nix
        ./hardware-configuration.nix
        ./configuration
      ];
    };
  };
}
