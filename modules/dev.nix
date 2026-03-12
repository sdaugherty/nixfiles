{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

{
  options.myConfig.modules.dev.enable = lib.mkEnableOption "Development tools";

  config = lib.mkIf config.myConfig.modules.dev.enable {
    nixpkgs.overlays = [ inputs.claude-desktop.overlays.default ];
    nixpkgs.config.android_sdk.accept_license = true; # required for android-studio

    environment.systemPackages = with pkgs; [
      go
      jetbrains.webstorm
      jetbrains.rust-rover
      jetbrains.pycharm
      jetbrains.idea
      jetbrains.goland
      jetbrains.dataspell
      jetbrains.datagrip
      android-studio
      uv
      nil
      vscode.fhs
      claude-code
      claude-desktop
      nixfmt
      nixbit
      nix-health
      direnv
      nix-direnv
      starship
      nerd-fonts.hack
      nerd-fonts.jetbrains-mono
      nerd-fonts.fira-mono
      nerd-fonts.fira-code
      upsun
      gemini-cli
      (python3.withPackages (
        python-pkgs: with python-pkgs; [
          pandas
          requests
        ]
      ))
    ];
  };
}
