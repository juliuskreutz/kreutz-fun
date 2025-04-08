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

  virtualisation.docker.enable = true;

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
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICPk9/NeWgM6Z7mJTLkmzBwD8bDPbddrdZ06Oril3597 bikerpenguin67"
  ];
  services.fail2ban.enable = true;

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_17;
  };

  services.caddy = {
    enable = true;
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
    gitMinimal
    htop
    curl
    vim
  ];

  system.stateVersion = "24.11";
}
