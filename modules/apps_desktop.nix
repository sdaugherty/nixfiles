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
          nativeBuildInputs = (oldAttrs.nativeBuildInputs or [ ]) ++ [ pkgs.python3 ];
          postInstall = (oldAttrs.postInstall or "") + ''
            # Replace bundled libvulkan.so.1 with system vulkan-loader so Discord's
            # VA-API/Vulkan video encoder and Chromium GPU process use the host driver stack
            ln -sf ${pkgs.vulkan-loader}/lib/libvulkan.so.1 $out/opt/Discord/libvulkan.so.1

            # Ensure libva always finds host VA-API drivers (/run/opengl-driver/lib/dri)
            sed -i '/--suffix VK_ADD_DRIVER_FILES/a \    --suffix LIBVA_DRIVERS_PATH : "${pkgs.addDriverRunpath.driverLink}/lib/dri" \\' \
              $out/opt/Discord/Discord

            # Patch app.asar and core.asar:
            # 1. Disable Chromium's LimitConcurrentDecoderInstances (caps VaapiVideoDecoder at 16 instances -> DecoderStatus::206)
            # 2. Enable AcceleratedVideoEncoder, VaapiIgnoreDriverChecks, VaapiOnNvidiaGPUs in Electron's enable-features
            # 3. Align hardcoded libopenh264-2.5.1-linux64.7.so filename with the 2.7.0 version downloaded by Discord's web client
            python3 - "$out/opt/Discord/resources/app.asar" "$out/opt/Discord/modules/discord_desktop_core/core.asar" <<'PY'
            import hashlib, json, struct, sys

            def patch_asar(path, entry_name, replacements):
                with open(path, "rb") as f:
                    data = f.read()
                _, _, _, json_len = struct.unpack("<4I", data[:16])
                header = json.loads(data[16:16 + json_len].decode("utf-8"))
                pad = (4 - (json_len % 4)) % 4
                payload_start = 16 + json_len + pad
                payload = data[payload_start:]

                b_info = header["files"][entry_name]
                b_off = int(b_info["offset"])
                b_size = b_info["size"]
                old_bundle = payload[b_off:b_off + b_size]
                new_bundle = old_bundle
                for old_bytes, new_bytes in replacements:
                    assert old_bytes in new_bundle, f"{old_bytes!r} not found in {path}:{entry_name}"
                    new_bundle = new_bundle.replace(old_bytes, new_bytes)

                delta = len(new_bundle) - len(old_bundle)
                b_info["size"] = len(new_bundle)
                new_hash = hashlib.sha256(new_bundle).hexdigest()
                b_info["integrity"]["hash"] = new_hash
                b_info["integrity"]["blocks"] = [new_hash]

                def shift_offsets(node):
                    if isinstance(node, dict):
                        if "offset" in node and int(node["offset"]) > b_off:
                            node["offset"] = str(int(node["offset"]) + delta)
                        for v in node.values():
                            shift_offsets(v)

                shift_offsets(header["files"])
                new_json = json.dumps(header, separators=(",", ":")).encode("utf-8")
                new_jlen = len(new_json)
                new_pad = (4 - (new_jlen % 4)) % 4
                aligned = new_jlen + new_pad
                new_hdr = struct.pack("<4I", 4, aligned + 8, aligned + 4, new_jlen) + new_json + (b"\x00" * new_pad)
                with open(path, "wb") as f:
                    f.write(new_hdr + payload[:b_off] + new_bundle + payload[b_off + b_size:])

            patch_asar(sys.argv[1], "bundle.js", [
                (
                    b'"linux"===process.platform&&disabledFeatures.push("WaylandWpColorManagerV1")',
                    b'"linux"===process.platform&&disabledFeatures.push("WaylandWpColorManagerV1","LimitConcurrentDecoderInstances")',
                ),
                (
                    b'appendSwitch("enable-features","DocumentPolicyIncludeJSCallStacksInCrashReports")',
                    b'appendSwitch("enable-features","DocumentPolicyIncludeJSCallStacksInCrashReports,AcceleratedVideoEncoder,VaapiIgnoreDriverChecks,VaapiOnNvidiaGPUs")',
                ),
                (
                    b"libopenh264-2.5.1-linux64.7.so",
                    b"libopenh264-2.7.0-linux64.8.so",
                ),
            ])
            patch_asar(sys.argv[2], "mainScreenPreload.js", [
                (
                    b"libopenh264-2.5.1-linux64.7.so",
                    b"libopenh264-2.7.0-linux64.8.so",
                ),
            ])
            PY
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
