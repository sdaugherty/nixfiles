{ config, pkgs, inputs, ... }:

{
  imports = [
    inputs.nix-index-database.nixosModules.nix-index
    ./apps.nix
    ./dev.nix
    ./gaming.nix
    ./emulators.nix
    ./kde.nix
    ./nvidia.nix
    ./amd.nix
  ];

  # nix-index configuration
  programs.nix-index.enable = true;
  programs.nix-index.package = inputs.nix-index.packages.${pkgs.system}.default;
  programs.nix-index-database.comma.enable = true;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest 6.18 kernel.
  boot.kernelPackages = pkgs.linuxPackages_6_18;

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

#  hardware.bluetooth.enable = true;   

hardware.bluetooth = {
  enable = true;
  powerOnBoot = true;
  settings = {
    General = {
      # Shows battery charge of connected devices on supported
      # Bluetooth adapters. Defaults to 'false'.
      Experimental = true;
      # When enabled other devices can connect faster to us, however
      # the tradeoff is increased power consumption. Defaults to
      # 'false'.
      FastConnectable = true;
    };
    Policy = {
      # Enable all controllers when they are found. This includes
      # adapters present on start as well as adapters that are plugged
      # in later on. Defaults to 'true'.
      AutoEnable = true;
    };
  };
};
 


  # firmware updates?
  services.fwupd.enable = true;

  # Enable periodic SSD trim.
  services.fstrim.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # device discovery so we can find printers
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.stephanie = {
    isNormalUser = true;
    description = "Stephanie Daugherty";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

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

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    bitwarden-desktop
    bitwarden-cli
    _1password-cli
    git
    fastfetch
    vim
    wget
    joe
    curl
    clamav
    clamtk
    ntfs3g
    mesa-demos
    ack
    lm_sensors
  ];

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}
