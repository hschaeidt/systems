{
  manager =
    { config, pkgs, ... }:
    { deployment.targetEnv = "virtualbox";
      deployment.virtualbox.memorySize = 1024; # MiB
      deployment.virtualbox.headless = true;

      # shared folders
      # http://nixos.org/nixops/manual/#opt-deployment.virtualbox.sharedFolders
      # Note: the shared folder 'key' is equal the 'device' in fileSystems in the following declaration
      deployment.virtualbox.sharedFolders = {
        Users = {
          hostPath = "/Users";
          readOnly = true;
        };
      };

      # mounting the above declared shared folder into the local file system
      # https://www.virtualbox.org/manual/ch04.html#sf_mount_manual
      # https://nixos.org/nixos/manual/#sec-instaling-virtualbox-guest
      fileSystems."/Users" = {
        fsType = "vboxsf";
        device = "Users";
        options = [ "rw" ];
      };
    };
}
