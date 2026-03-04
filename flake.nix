{
  description = "A NixOS configuration with flakes";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-master.url = "github:nixos/nixpkgs/master";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    claude-desktop.url = "github:aaddrick/claude-desktop-debian";
  };

  outputs = { self, nixpkgs, nixpkgs-master, home-manager, ... }@inputs: {
    packages.x86_64-linux.calibre = nixpkgs-master.legacyPackages.x86_64-linux.calibre;
    nixosConfigurations = {
      mystra = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/mystra/configuration.nix
          #home-manager.nixosModules.home-manager
          #{
          #  home-manager.useGlobalPkgs = true;
          #  home-manager.useUserPackages = true;
          #  home-manager.users.stephanie = import ./home-manager/home.nix;
          #}
        ];
      };
      sune = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/sune/configuration.nix
          #home-manager.nixosModules.home-manager
          #{
          #  home-manager.useGlobalPkgs = true;
          #  home-manager.useUserPackages = true;
          #  home-manager.users.stephanie = import ./home-manager/home.nix;
          #}
        ];
      };
      akadi = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/akadi/configuration.nix
          #home-manager.nixosModules.home-manager
          #{
          #  home-manager.useGlobalPkgs = true;
          #  home-manager.useUserPackages = true;
          #  home-manager.users.stephanie = import ./home-manager/home.nix;
          #}
        ];
      };
    };
  };
}
