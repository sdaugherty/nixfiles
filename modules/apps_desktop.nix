{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

{
  options.myConfig.modules.apps_desktop.enable = lib.mkEnableOption "Desktop applications";

  config = lib.mkIf config.myConfig.modules.apps_desktop.enable {
    # nixpkgs.overlays = [ inputs.affinity-nix.overlays.default ];

    programs.firefox.enable = true;
    programs.steam = {
      enable = true;
      protontricks.enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
      localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
      extraPackages = with pkgs; [
        qogir-icon-theme
        steamtinkerlaunch
        corefonts
        winetricks
      ];
      extraCompatPackages = with pkgs; [
        steamtinkerlaunch
      ];
      fontPackages = with pkgs; [
        corefonts
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-color-emoji
        liberation_ttf
        fira-code
        fira-code-symbols
        mplus-outline-fonts.githubRelease
        dina-font
        proggyfonts
      ];
    };

    hardware.openrazer.enable = true;

    # dialout lets CHIRP talk to radio programming cables (/dev/ttyUSB*) without sudo
    users.users.stephanie.extraGroups = [ "dialout" ];

    programs._1password-gui = {
      enable = true;
      polkitPolicyOwners = [ "stephanie" ];
    };


    fonts.packages = with pkgs; [
      nerd-fonts.fira-code
      nerd-fonts.droid-sans-mono
      corefonts
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      liberation_ttf
      fira-code
      fira-code-symbols
      mplus-outline-fonts.githubRelease
      dina-font
      proggyfonts
    ];

    fonts.enableDefaultPackages = true;

    environment.systemPackages =
      let
        discordBase = pkgs.callPackage "${inputs.nixpkgs-unstable}/pkgs/by-name/di/discord/package.nix" {
          useFHSEnv = true;
        };
        discordUnwrapped = discordBase.passthru.unwrappedDiscord.overrideAttrs (oldAttrs: {
          postInstall = (oldAttrs.postInstall or "") + ''
            # Replace bundled libvulkan.so.1 with system vulkan-loader so Discord's
            # VA-API/Vulkan video encoder and Chromium GPU process use the host driver stack
            ln -sf ${pkgs.vulkan-loader}/lib/libvulkan.so.1 $out/opt/Discord/libvulkan.so.1

            # Ensure libva always finds host VA-API drivers (/run/opengl-driver/lib/dri)
            sed -i '/--suffix VK_ADD_DRIVER_FILES/a \    --suffix LIBVA_DRIVERS_PATH : "${pkgs.addDriverRunpath.driverLink}/lib/dri" \\' \
              $out/opt/Discord/Discord

            # Disable ImageQualitySink self-decode VMAF/PSNR loop on outgoing streams,
            # which spins up extra hardware decoders and crashes the renderer thread on Linux
            substituteInPlace $out/opt/Discord/modules/discord_voice/index.js \
              --replace-fail "features.declareSupported('image_quality_measurement');" "// features.declareSupported('image_quality_measurement');"
          '';
          passthru = oldAttrs.passthru // {
            targetPkgs =
              pkgs':
              (oldAttrs.passthru.targetPkgs pkgs')
              ++ (with pkgs'; [
                vulkan-loader
                libxshmfence
                libvdpau
                openh264
              ]);
          };
        });
        discordCustom = discordBase.override {
          unwrappedDiscord = discordUnwrapped;
        };
      in
      with pkgs; [
      libreoffice-qt-fresh
      obsidian
      discordCustom
      typora
      vlc
      kdePackages.kdenlive
      captive-browser
      deezer-enhanced
      zoom-us
      kdePackages.isoimagewriter
      kdePackages.kcalc
      kdePackages.kcharselect
      kdePackages.konversation
      kdePackages.neochat
      kdePackages.kio
      kdePackages.kio-fuse
      kdePackages.kio-gdrive
      kdePackages.kio-extras
      kdePackages.kdesdk-kio
      kdePackages.kio-zeroconf
      kdePackages.dolphin-plugins
      kdePackages.filelight
      kdePackages.kaccounts-providers
      kdePackages.kaccounts-integration
      kaidan
      gramps
      pan
      lyx
      yad
      corefonts
      xwininfo
      xdotool
      kdotool
      yubioath-flutter
      inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.alpaca
      kdePackages.alpaka
      chirp
      thunderbird
      wineWow64Packages.stable
      winetricks
      q4wine
      #protontricks
      protonup-ng
      protonplus
      super-productivity
      adoptopenjdk-icedtea-web
      orca-slicer
      bubblewrap
      inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.calibre
      # affinity-v3
      openrazer-daemon
      polychromatic
      (pkgs.wrapOBS {
        plugins = with pkgs.obs-studio-plugins; [
          wlrobs
          obs-backgroundremoval
         obs-pipewire-audio-capture
        ];
      })


    ];

    xdg.mime.defaultApplications = {
      "text/html" = "org.mozilla.firefox";
      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";
      "x-scheme-handler/about" = "firefox.desktop";
      "x-scheme-handler/unknown" = "firefox.desktop";
    };
  };
}
