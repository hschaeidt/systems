{
  manager = {config, pkgs, ...}:
  {
    services.gitlab-runner.enable = true;
    services.gitlab-runner.configText = ''
concurrent = 1
check_interval = 0

[[runners]]
  name = "manager"
  url = "https://gitlab.com/ci"
  token = "7d52ff93b9e0e24e371ab5edca4131"
  executor = "shell"
  [runners.cache]
'';
    environment.systemPackages = [
      pkgs.nixops
      pkgs.gitlab-runner
    ];

    users.extraUsers.gitlab-runner = {
      shell = "/run/current-system/sw/bin/bash";
    };
  };
}
