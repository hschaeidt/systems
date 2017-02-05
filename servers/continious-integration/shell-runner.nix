{
  shell-runner =
    { pkgs, config, ... }:
    {
      services.gitlab-runner = {
        enable = true;
        configText = ''
          concurrent = 1
          check_interval = 0

          [[runners]]
            name = "shell-runner"
            url = "https://gitlab.com/ci"
            token = "7d52ff93b9e0e24e371ab5edca4131"
        '';
      };
    };
}