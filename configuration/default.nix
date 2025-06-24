{
  pkgs,
  ...
}:
{
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nixpkgs.config.allowUnfree = true;

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
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOsDtcDaujekE00RIsccA/lhse1vzHuJxO5TYp+G9X4M gitlab"
  ];
  services.fail2ban.enable = true;

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
    htop
    curl
    vim
  ];

  services.caddy = {
    enable = true;
    virtualHosts."prod.kreutz.fun".extraConfig = ''
      reverse_proxy localhost:3000
    '';
    virtualHosts."dev.kreutz.fun".extraConfig = ''
      reverse_proxy localhost:3001
    '';
  };

  systemd.services.rezepte-ui-prod = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      WorkingDirectory = "/root/rezepte-ui-prod";
      ExecStart = "${pkgs.bun}/bin/bun run start";
    };
  };

  systemd.services.rezepte-ui-dev = {
    wantedBy = [ "multi-user.target" ];
    environment = {
      PORT = "3001";
    };
    serviceConfig = {
      WorkingDirectory = "/root/rezepte-ui-dev";
      ExecStart = "${pkgs.bun}/bin/bun run start";
    };
  };

  system.stateVersion = "24.11";
}
