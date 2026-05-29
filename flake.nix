{
  description = "A NixOS configuration with flakes";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-kernel.url = "github:nixos/nixpkgs/47472570b1e607482890801aeaf29bfb749884f6";
    nixpkgs-master.url = "github:nixos/nixpkgs/master";
    nixpkgs-stable.url = "github:nixos/nixpkgs/b86751bc4085f48661017fa226dee99fab6c651b";
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
        specialArgs = { inherit inputs; };
        modules = [
          { nixpkgs.hostPlatform = "x86_64-linux"; }
          ./hosts/mystra/configuration.nix
        ];
      };
      sune = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          { nixpkgs.hostPlatform = "x86_64-linux"; }
          ./hosts/sune/configuration.nix
        ];
      };
      akadi = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          { nixpkgs.hostPlatform = "x86_64-linux"; }
          ./hosts/akadi/configuration.nix
        ];
      };
      waukeen = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          { nixpkgs.hostPlatform = "aarch64-linux"; }
          ./hosts/waukeen/configuration.nix
        ];
      };
      lathander = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          { nixpkgs.hostPlatform = "x86_64-linux"; }
          ./hosts/lathander/configuration.nix
        ];
      };
      istishia = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          { nixpkgs.hostPlatform = "x86_64-linux"; }
          ./hosts/istishia/configuration.nix
        ];
      };
    };
  };
}
