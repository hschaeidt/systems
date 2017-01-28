{
  network.description = "probitc";

  probitc = { config, pkgs, ... }:
  {
    environment.systemPackages = [
      pkgs.vim
    ];
  };
}
