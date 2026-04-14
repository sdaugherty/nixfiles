{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    inputs.nix-index-database.nixosModules.nix-index
    ./apps_cli.nix
    ./apps_desktop.nix
    ./dev_cli.nix
    ./dev_desktop.nix
    ./gaming_desktop.nix
    ./emulators_desktop.nix
    ./kde_desktop.nix
    ./niri_desktop.nix
    ./cinnamon_desktop.nix
    ./nvidia_desktop.nix
    ./amd_desktop.nix
    ./grocy_cli.nix
  ];

  options.myConfig.modules = {
    common_cli.enable = lib.mkEnableOption "Common CLI services and applications";
    common_desktop.enable = lib.mkEnableOption "Common desktop services and applications";
  };



  config = lib.mkMerge [
    (lib.mkIf config.myConfig.modules.common_cli.enable {
      # nix-index configuration
      programs.nix-index.enable = true;
      programs.nix-index.package = inputs.nix-index.packages.${pkgs.system}.default;
      programs.nix-index-database.comma.enable = true;

      # Bootloader.
      boot.loader.systemd-boot.enable = lib.mkDefault true;
      boot.loader.efi.canTouchEfiVariables = lib.mkDefault true;

      # Use the latest stable kernel.
      boot.kernelPackages = pkgs.linuxPackages_latest;

      # Enable networking
      networking.networkmanager.enable = true;

      # Set your time zone.
      time.timeZone = "America/New_York";

      # Select internationalisation properties.
      i18n.defaultLocale = "en_US.UTF-8";

      i18n.extraLocaleSettings = {
        LC_ADDRESS = "en_US.UTF-8";
        LC_IDENTIFICATION = "en_US.UTF-8";
        LC_MEASUREMENT = "en_US.UTF-8";
        LC_MONETARY = "en_US.UTF-8";
        LC_NAME = "en_US.UTF-8";
        LC_NUMERIC = "en_US.UTF-8";
        LC_PAPER = "en_US.UTF-8";
        LC_TELEPHONE = "en_US.UTF-8";
        LC_TIME = "en_US.UTF-8";
      };

      # Enable periodic SSD trim.
      services.fstrim.enable = true;

      # Define a user account. Don't forget to set a password with ‘passwd’.
      users.users.stephanie = {
        isNormalUser = true;
        description = "Stephanie Daugherty";
        extraGroups = [
          "networkmanager"
          "wheel"
        ];
      };

      users.users.root.openssh.authorizedKeys.keys = [''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPmTkcqfVI29TNfSaLBs0sY37bF9GrXAuPN00C6zti/K stephanie@mystra'' ];

      # nix-command and enable - flakes would go here too
      nix.settings.experimental-features = [ "nix-command" "flakes" ];

      # Allow unfree packages
      nixpkgs.config.allowUnfree = true;

      # debugging symbols
      environment.enableDebugInfo = true;

      # security override for package vulerabilities
      nixpkgs.config.permittedInsecurePackages = [
        "olm-3.2.16"
      ];

      # List packages installed in system profile.
      environment.systemPackages = with pkgs; [
        git
        vim
        wget
        curl
        nh
      ];

      # Enable the OpenSSH daemon.
      services.openssh.enable = true;

      # Firewall configuration
      networking.firewall.enable = false;

      # stateVersion
      system.stateVersion = "25.11";
    })

    (lib.mkIf config.myConfig.modules.common_desktop.enable {
      hardware.bluetooth = {
        enable = true;
        powerOnBoot = true;
        settings = {
          General = {
            Experimental = true;
            FastConnectable = true;
          };
          Policy = {
            AutoEnable = true;
          };
        };
      };

      services.fwupd.enable = true;
      services.printing.enable = true;

      services.avahi = {
        enable = true;
        nssmdns4 = true;
        openFirewall = true;
      };

      services.pulseaudio.enable = false;
      security.rtkit.enable = true;
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
      };

      environment.systemPackages = with pkgs; [
        bitwarden-desktop
        clamtk
        mesa-demos
      ];
    })
  ];
}
