{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    go
    jetbrains.webstorm
    jetbrains.rust-rover
    jetbrains.pycharm
    jetbrains.idea
    jetbrains.goland
    jetbrains.dataspell
    jetbrains.datagrip
    uv
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
    gemini-cli
    (python3.withPackages (
      python-pkgs: with python-pkgs; [
        pandas
        requests
      ]
    ))
  ];
}
