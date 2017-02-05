{
  shell-runner =
    { config, pkgs, ... }:
    { deployment.targetEnv = "virtualbox";
      deployment.virtualbox.memorySize = 1024; # MiB
      deployment.virtualbox.headless = true;
    };
}
