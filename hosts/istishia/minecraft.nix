{ inputs, pkgs, lib, ... }:
let
  modpack = pkgs.fetchModrinthModpack {
    src = ../../files/mothcraft.mrpack;
    packHash = "sha256-HugmmSRhqvf2QSjo8dLk1mXk4Ww9aEnofDIoUpqwtVw=";
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
        jre_headless = pkgs.jdk25;
      };
      whitelist = {
        MothTheGoblin = "114354f7-e737-490d-8393-2a4d989cecc7";
        ancientstephanie = "c29e3b52-dd9c-4767-9519-657bcea0909d";
      };

      operators = {
        MothTheGoblin = "114354f7-e737-490d-8393-2a4d989cecc7";
        ancientstephanie = "c29e3b52-dd9c-4767-9519-657bcea0909d";
      };

      serverProperties = {
        white-list = true;
        enforce-whitelist = true;
        level-seed = "-6446031685201032150";
      };

      symlinks = {
        "mods" = "${modpack}/mods";
      };
    };
  };
}
