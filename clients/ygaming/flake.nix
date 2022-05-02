{
  description = "NixOS-WSL on the yGaming Host";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-21.11";
    nixos-wsl.url = "github:hschaeidt/nixos-wsl/21.11";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, nixos-wsl, ... }@attrs: {
    nixosConfigurations.ygaming = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = attrs;
      modules = [
        ./configuration.nix
        nixos-wsl.nixosModules.wsl
        {
          wsl = {
            enable = true;
            automountPath = "/mnt";
            defaultUser = "nixos";
            startMenuLaunchers = true;
            docker.enable = true;
          };
        }
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = attrs;
          home-manager.users.nixos = import ./home.nix;
        }
      ];
    };
  };
}
