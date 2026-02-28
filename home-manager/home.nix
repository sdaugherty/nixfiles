{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "stephanie";
  home.homeDirectory = "/home/stephanie";

  # This value determines the Home Manager release that Home Manager
  # backwards compatibility and warnings would be enabled. Before
  # changing this value read the documentation for this option
  # (e.g. man home-configuration.nix or on https://nixos.org/nixos/options.html).
  home.stateVersion = "25.11";

  # The starship prompt
  programs.starship = {
    enable = true;
    # Configuration written to ~/.config/starship.toml
    settings = {
      add_newline = false;
      command_timeout = 1000;
      format = "$all";
      line_break.disabled = true;
      aws.disabled = true;
      gcloud.disabled = true;
      character = {
        success_symbol = "[λ](bold green)";
        error_symbol = "[λ](bold red)";
        vimcmd_symbol = "[λ](bold green)";
      };
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
