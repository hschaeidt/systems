{
  manager =
    { config, pkgs, ... }:
    { deployment.targetEnv = "virtualbox";
      deployment.virtualbox.memorySize = 1024; # MiB
      deployment.virtualbox.headless = true;
      deployment.virtualbox.sharedFolders = {
        home = {
          hostPath = "/Users/hschaeidt";
          readOnly = false;
        };
      };
    };
}
