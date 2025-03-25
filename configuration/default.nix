{
  pkgs,
  ...
}:
{
  imports = [
    ./gitea.nix
    ./grafana.nix
    ./mirrorfour-api.nix
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICVYTxSfsoGYBKzuSc9Q4Fc8zuCtumj3Nw6ZxwYDBUaS julius"
  ];
  services.fail2ban.enable = true;

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_17;
    initialScript = pkgs.writeText "init.sql" ''
      CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
    '';
    settings.shared_preload_libraries = [ "pg_stat_statements" ];
  };

  services.caddy = {
    enable = true;
    globalConfig = ''
      metrics {
          per_host
      }
    '';
  };

  networking.nftables.enable = true;
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      22
      80
      443
    ];
  };

  environment.systemPackages = with pkgs; [
    curl
  ];

  system.stateVersion = "24.05";
}
