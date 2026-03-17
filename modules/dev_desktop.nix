{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

{
  options.myConfig.modules.dev_desktop.enable = lib.mkEnableOption "Desktop development tools";

  config = lib.mkIf config.myConfig.modules.dev_desktop.enable {
    nixpkgs.overlays = [ inputs.claude-desktop.overlays.default ];
    nixpkgs.config.android_sdk.accept_license = true; # required for android-studio

    environment.systemPackages = with pkgs; [
      jetbrains.webstorm
      jetbrains.rust-rover
      jetbrains.pycharm
      jetbrains.idea
      jetbrains.goland
      jetbrains.dataspell
      jetbrains.datagrip
      android-studio
      vscode.fhs
      claude-desktop
      nerd-fonts.hack
      nerd-fonts.jetbrains-mono
      nerd-fonts.fira-mono
      nerd-fonts.fira-code
    ];
  };
}
