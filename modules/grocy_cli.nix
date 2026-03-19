{
  pkgs,
  lib,
  config,
  ...
}:

{
  options.myConfig.modules.grocy_cli.enable = lib.mkEnableOption "Grocy web app";

  config = lib.mkIf config.myConfig.modules.grocy_cli.enable {
    services.grocy = {
      enable = true;
      hostName = "grocy.istishia.scratchingpost.xyz";
      settings = {
        currency = "USD";
        culture = "en";
      };
    };

    services.nginx.enable = true;
    networking.firewall.allowedTCPPorts = [ 80 443 ];

    security.acme = {
      acceptTerms = true;
      defaults.email = "domains@stephaniedaugherty.com";
    };
  };
}
