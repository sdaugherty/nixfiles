{ inputs, pkgs, lib, ... }:
let
  # Voxy's RocksDB JNI native library requires libstdc++.so.6 at runtime.
  # Wrap the JRE so LD_LIBRARY_PATH includes it (NixOS doesn't expose it otherwise).
  zulu25-with-stdcpp = pkgs.symlinkJoin {
    name = "zulu25-with-stdcpp";
    paths = [ pkgs.zulu25 ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/java \
        --prefix LD_LIBRARY_PATH : "${pkgs.stdenv.cc.cc.lib}/lib"
    '';
    meta.mainProgram = "java";
  };

  modpack = (pkgs.fetchModrinthModpack {
    src = ../../files/mothcraft.mrpack;
    packHash = "sha256-HugmmSRhqvf2QSjo8dLk1mXk4Ww9aEnofDIoUpqwtVw=";
    side = "server";
  }).addFiles {
    # Voxy is marked server-unsupported in the mrpack but is required by VoxyServer
    "mods/voxy-0.2.18-beta.jar" = pkgs.fetchurl {
      url = "https://cdn.modrinth.com/data/fxxUqruK/versions/zZX86mbc/voxy-0.2.18-beta.jar";
      hash = "sha256-3Z4Q0hEIefB8HOm98ZRfNHCzLoOXfwlABe6MZC6BKNU=";
    };
    "mods/voicechat-fabric-2.6.21+26.2.jar" = pkgs.fetchurl {
      url = "https://cdn.modrinth.com/data/9eGKb6K1/versions/3SOh5iiX/voicechat-fabric-2.6.21%2B26.2.jar";
      hash = "sha256-7V+hoRf6Jr+8hGPCf4io3/xT2id3gfJm7RESKB9/Zfc=";
    };
    "mods/villagercycle-1.5.0+26.2.jar" = pkgs.fetchurl {
      url = "https://cdn.modrinth.com/data/lI4LXqQa/versions/IHbkLguL/villagercycle-1.5.0%2B26.2.jar";
      hash = "sha256-Pw362vtZRYKpkWt9jizgFMYYdoUQSsXhB01Ghym3bfg=";
    };
    "mods/ferritecore-9.0.0-fabric.jar" = pkgs.fetchurl {
      url = "https://cdn.modrinth.com/data/uXXizFIs/versions/d5ddUdiB/ferritecore-9.0.0-fabric.jar";
      hash = "sha256-ITlmxy7ZZ6zHOSvrKKhm+6MB/1a5l2wueAHC233mvyI=";
    };
    "mods/modernfix-5.27.19-build.1.jar" = pkgs.fetchurl {
      url = "https://cdn.modrinth.com/data/TjSm1wrD/versions/TUWH6NZu/modernfix-5.27.19-build.1.jar";
      hash = "sha256-+dC4muUeRDZGbe1IxF/sNSizzKBXmcspg3zwroGgip0=";
    };
    "mods/spark-1.10.173-fabric.jar" = pkgs.fetchurl {
      url = "https://cdn.modrinth.com/data/l6YH9Als/versions/iYFOl6lQ/spark-1.10.173-fabric.jar";
      hash = "sha256-B27SKI2yoFym6AYWFeGjHRkSzxsQZl5PCaF5TV25lDM=";
    };
    "mods/imfast-FABRIC-26.2-1.0.3.jar" = pkgs.fetchurl {
      url = "https://cdn.modrinth.com/data/PaUMOeP0/versions/nD5sET2x/imfast-FABRIC-26.2-1.0.3.jar";
      hash = "sha512-ZkYG60Hb8TOF7IJUXDCnsRi9JjOTMlwppqbu9uCjkFVcGU4MFd9kwY1/R3NExCPlGOZ7SB1ckXH9XH+zZ5U0Gw==";
    };
    "mods/bettercoppergolem-FABRIC-2.3.0-26.2.jar" = pkgs.fetchurl {
      url = "https://cdn.modrinth.com/data/FD3rofvj/versions/hObU3vIn/bettercoppergolem-FABRIC-2.3.0-26.2.jar";
      hash = "sha512-m4QNhowE0qASpFScM5XCklbamgDNzMeIAc2SmmvtCNeFVCYB/EMwBp7F7I/4K4HT6awusy5weYyUrjc74rz4mQ==";
    };
    "mods/simple-crop-harvester-1.0.1.jar" = pkgs.fetchurl {
      url = "https://cdn.modrinth.com/data/YU24fvmk/versions/XL1z7zbU/simple-crop-harvester-1.0.1.jar";
      hash = "sha512-31LV+UQxbx2IPdvqshsDq/GC2S/LJo8wGp3hLLYiq76Xl6nW+lC0oGlWA7nxBp37BqlrlkgDV6wpJ7Gao2SnOA==";
    };
    "mods/simple_villager_follow-26.1.2-Fabric-1.0.0.jar" = pkgs.fetchurl {
      url = "https://cdn.modrinth.com/data/TLfqKtxl/versions/68fCp7ce/simple_villager_follow-26.1.2-Fabric-1.0.0.jar";
      hash = "sha512-k5aAzUHYn0TXtFRMcxwF5FpHP/YXRYjhTxyfJljXYOBgLXxHG+Mff3D9Vr3NhC5WQR/yPG6hBF74T+T6HegD8g==";
    };
  };

  # Datapacks (not Fabric mods) symlinked wholesale into the world's datapacks folder.
  datapacks = pkgs.linkFarm "mothcraft-datapacks" {
    "superiorstonecutter-v1.3.1.zip" = pkgs.fetchurl {
      url = "https://cdn.modrinth.com/data/yWBAOWPN/versions/2tEzj9sa/superiorstonecutter-v1.3.1.zip";
      hash = "sha512-uGgAviVxsi943NHhdJLPOX0mu3vreNZHVGuA2BlkRF5yjc2kWKkCXThQEtbwYZkyl+bf+dtq5iAS4rYjUh2FKQ==";
    };
    "superiorsmelting-v1.2.3.zip" = pkgs.fetchurl {
      url = "https://cdn.modrinth.com/data/2DtbGsFA/versions/OYc2z2vR/superiorsmelting-v1.2.3.zip";
      hash = "sha512-G7m47Isp2p89XEGf0dWsolbq6tB5QkS9AekihHX92gorlcPWgPmbDeJtUxkqawiDmezFrrVv/HeTAMi0RrNMjg==";
    };
  };

  # Shared between both servers so whitelist/ops stay in sync.
  players = {
    MothTheGoblin = "114354f7-e737-490d-8393-2a4d989cecc7";
    ancientstephanie = "c29e3b52-dd9c-4767-9519-657bcea0909d";
  };

  fabricPackage = pkgs.fabricServers.fabric-26_2.override {
    loaderVersion = "0.19.3";
    jre_headless = zulu25-with-stdcpp;
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
      package = fabricPackage;
      whitelist = players;
      operators = players;

      jvmOpts = "-Xms2G -Xmx6G";

      serverProperties = {
        white-list = true;
        enforce-whitelist = true;
        level-seed = "-6446031685201032150";
        allow-flight = true;
      };

      symlinks = {
        "mods" = "${modpack}/mods";
        "world/datapacks" = datapacks;
      };

      files = {
        "config/voicechat/voicechat-server.properties".value = {
          port = 24454;
        };
      };
    };

    servers.mothcraft-creative = {
      enable = true;
      package = fabricPackage;
      whitelist = players;
      operators = players;

      jvmOpts = "-Xms2G -Xmx6G";

      serverProperties = {
        white-list = true;
        enforce-whitelist = true;
        server-port = 25566;
        gamemode = 1;
        level-type = "minecraft:flat";
        allow-flight = true;
      };

      symlinks = {
        "mods" = "${modpack}/mods";
        "world/datapacks" = datapacks;
      };

      files = {
        "config/voicechat/voicechat-server.properties".value = {
          port = 24455;
        };
      };
    };
  };

  networking.firewall.allowedUDPPorts = [ 24454 24455 ];
}
