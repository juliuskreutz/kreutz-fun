{
  inputs,
  ...
}:
{
  imports = [
    inputs.mirrorfour-api.nixosModules.mirrorfour-api
  ];

  services.mirrorfour-api = {
    enable = true;
    sessionKey = "gq69au0WnewkcSSJqnwVeIsSH9lvc6BNCFe4Jgg5Zdm5CrEh3hZLK9zQXfSezs7TIAa53aOPLeYG6KbCkJo3mw==";
  };

  services.caddy = {
    virtualHosts."m4.kreutz.fun".extraConfig = ''
      reverse_proxy http://localhost:8000
    '';
  };
}
