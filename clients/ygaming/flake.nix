{
  description = "NixOS-WSL on the yGaming Host";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-21.11";
    nixos-wsl.url = "github:hschaeidt/nixos-wsl";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nixpkgs, home-manager, nixos-wsl, ... }: {
    nixosConfigurations.ygaming = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        nixos-wsl.nixosModules.wsl
        {
          wsl = {
            enable = true;
            automountPath = "/mnt";
            defaultUser = "nixos";
            startMenuLaunchers = true;
            docker-desktop.enable = true;
          };
        }
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.nixos = import ./home.nix;
        }
      ];
    };
  };
}
