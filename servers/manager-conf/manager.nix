{
  manager = {config, pkgs, ...}:
  {
    environment.systemPackages = [
      pkgs.nixops
      pkgs.borgbackup
      pkgs.ag
    ];
  };
}
