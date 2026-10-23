{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

{
  options.myConfig.modules.dev_cli.enable = lib.mkEnableOption "CLI development tools";

  config = lib.mkIf config.myConfig.modules.dev_cli.enable {
    environment.systemPackages = with pkgs; [
      go
      uv
      nil
      claude-code
      nixfmt
      nixbit
      nix-health
      direnv
      nix-direnv
      starship
      upsun
      gemini-cli
      inputs.nixpkgs-master.legacyPackages.${pkgs.stdenv.hostPlatform.system}.antigravity-cli
      (python3.withPackages (
        python-pkgs: with python-pkgs; [
          pandas
          requests
        ]
      ))
    ];
  };
}
