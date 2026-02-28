{ pkgs, ... }:

{
  programs.firefox.enable = true;
  programs.steam.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "stephanie" ];
  };

  environment.systemPackages = with pkgs; [
    libreoffice-qt-fresh
    obsidian
    discord
    typora
    captive-browser
    deezer-enhanced
    zoom-us
    kdePackages.isoimagewriter
    kdePackages.kcalc
    kdePackages.kcharselect
    kdePackages.konversation
    kdePackages.neochat
    kaidan
    irssi
  ];

  xdg.mime.defaultApplications = {
    "text/html" = "org.mozilla.firefox";
    "x-scheme-handler/http" = "firefox.desktop";
    "x-scheme-handler/https" = "firefox.desktop";
    "x-scheme-handler/about" = "firefox.desktop";
    "x-scheme-handler/unknown" = "firefox.desktop";
  };
}
