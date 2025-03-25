{
  config,
  ...
}:
{
  services.gitea = {
    enable = true;
    database.type = "postgres";
    # Enable support for Git Large File Storage
    lfs.enable = true;
    settings = {
      server = rec {
        DOMAIN = "git.kreutz.fun";
        # You need to specify this to remove the port from URLs in the web UI.
        ROOT_URL = "https://${DOMAIN}/";
        HTTP_PORT = 3200;
      };
      # You can temporarily allow registration to create an admin user.
      service.DISABLE_REGISTRATION = true;
    };
  };

  services.caddy = {
    virtualHosts.${config.services.gitea.settings.server.DOMAIN}.extraConfig = ''
      reverse_proxy http://localhost:${toString config.services.gitea.settings.server.HTTP_PORT}
    '';
  };
}
