{
  manager = {config, pkgs, ...}:
  {
    virtualisation.docker.enable = true;

    services.gitlab-runner = {
      enable = true;
      configText = ''
        concurrent = 1
        check_interval = 0

        [[runners]]
          name = "docker-runner"
          url = "https://gitlab.com/ci"
          token = "7d52ff93b9e0e24e371ab5edca4131"
          executor = "docker"
          [runners.docker]
            tls_verify = false
            image = "ubuntu:latest"
            privileged = false
            disable_cache = false
            volumes = ["/cache"]
          [runners.cache]
            Type = "s3"
            ServerAddress = "http://127.0.0.1:9005"
            AccessKey = "2XFZ4GUHYYO6M1UU4SFY"
            SecretKey = "MToIJfOGVu3h6KGJB8Ohh8SnI1kQq+TJ2OgsknHy"
            BucketName = "runner"
            Insecure = true
        '';
    };
  };
}
