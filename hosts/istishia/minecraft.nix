{ inputs, pkgs, lib, ... }:
let
  modpack = pkgs.fetchModrinthModpack {
    src = ../../files/mothcraft.mrpack;
    packHash = lib.fakeHash;
    side = "server";
  };
in
{
  imports = [ inputs.nix-minecraft.nixosModules.minecraft-servers ];

  nixpkgs.overlays = [ inputs.nix-minecraft.overlay ];

  services.minecraft-servers = {
    enable = true;
    eula = true;
    openFirewall = true;

    servers.mothcraft = {
      enable = true;
      package = pkgs.fabricServers.fabric-26_2.override {
        loaderVersion = "0.19.3";
      };
      symlinks = {
        "mods" = "${modpack}/mods";
      };
    };
  };
}
