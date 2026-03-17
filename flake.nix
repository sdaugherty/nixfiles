{
  description = "A NixOS configuration with flakes";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-master.url = "github:nixos/nixpkgs/master";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index.url = "github:nix-community/nix-index";
    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    affinity-nix.url = "github:mrshmllow/affinity-nix";
    claude-desktop.url = "github:aaddrick/claude-desktop-debian";
    hytale-launcher.url = "github:JPyke3/hytale-launcher-nix";
  };

  outputs = { self, nixpkgs, nixpkgs-master, home-manager, ... }@inputs: {
    packages.x86_64-linux.calibre = nixpkgs-master.legacyPackages.x86_64-linux.calibre;
    nixosConfigurations = {
      mystra = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/mystra/configuration.nix
        ];
      };
      sune = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/sune/configuration.nix
        ];
      };
      akadi = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/akadi/configuration.nix
        ];
      };
      waukeen = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/waukeen/configuration.nix
        ];
      };
      lathander = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/lathander/configuration.nix
        ];
      };
      istishia = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/istishia/configuration.nix
        ];
      };
    };
  };
}
