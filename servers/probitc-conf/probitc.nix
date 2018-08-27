{
  network.description = "probitc";
  network.enableRollback = true;

  probitc = { config, pkgs, ... }:
  {
    environment.systemPackages = with pkgs; [
      borgbackup
    ];

    networking = {
      firewall = {
        enable = true;
        allowedTCPPorts = [
          22
          80
          443
          # matrix-synapse federation
          # https://matrix.org/federationtester/api/report?server_name=schaeidt.net
          8448
        ];
      };
    };

    # backup-all service collects all user modified data
    # the backup service is started once per hour by a systemd timer declared below
    #
    # > The root ssh key is registered on the target machine for the borg user.
    # > Following environment variables are set in the `.config/bash/environment`
    #   export BORG_REPO='user@host:root@hostname.local'
    #   export BORG_PASSPHRASE='some secret passphrase'
    #   export SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/ssh-agent
    # > The backup folder has to be initialized manually
    #   `borg init user@host:root@hostname.local`
    # > To start a backup manually `systemctl start backup-all.service`
    systemd.services.backup-all = {
      description = "Backing up the system";
      path = [ pkgs.borgbackup pkgs.openssh ];
      script = ''
        # Load environment variables with repository, passphrase, and ssh auth-sock
        source /root/.config/bash/environment

        # Backup all system customized files including users home folders
        ${pkgs.borgbackup}/bin/borg create -v --stats \
          ::'{hostname}-{now:%Y-%m-%d_%H-%M}' \
          / \
          --exclude '/dev'                \
          --exclude '/nix'                \
          --exclude '/tmp'                \
          --exclude '/mnt'                \
          --exclude '/proc'               \
          --exclude '/sys'                \
          --exclude-caches                \
          --exclude '/home/*/.cache/*'    \
          --exclude '/var/cache/*'        \
          --exclude '/var/tmp/*'          

        # Use the `prune` subcommand to maintain 24 hourly, 7 daily, 4 weekly and 6 monthly
        ${pkgs.borgbackup}/bin/borg prune -v --list --prefix '{hostname}-' \
          --keep-hourly=24 --keep-daily=7 --keep-weekly=4 --keep-monthly=6
      '';
    };

    # Timer job for the backup-all service
    systemd.timers.backup-all = {
      description = "Backup timer for the system";
      partOf = [ "backup-all.service" ];
      wantedBy = [ "timers.target" ];
      timerConfig.OnCalendar = "hourly";
    };


    services = {
      fail2ban.enable = true;
      searx.enable = true;

      nginx = {
        enable = true;
        recommendedTlsSettings = true;
        recommendedOptimisation = true;
        recommendedGzipSettings = true;
        recommendedProxySettings = true;

        virtualHosts = {
          "schaeidt.net" = {
            serverName = "schaeidt.net";
            forceSSL = true;
            enableACME = true;

            locations = {
              # Reverse Proxy for matrix-synapse service
              "/_matrix" = {
                proxyPass = "http://127.0.0.1:8008";
                extraConfig = ''
                  proxy_set_header X-Forwarded-For $remote_addr;
                '';
              };
            };
          };

          "search.schaeidt.net" = {
            serverName = "search.schaeidt.net";
            forceSSL = true;
            enableACME = true;

            locations = {
              "/" = {
                proxyPass = "http://127.0.0.1:8888";
                extraConfig = ''
                  proxy_set_header        Host                 $host;
                  proxy_set_header        X-Real-IP            $remote_addr;
                  proxy_set_header        X-Forwarded-For      $proxy_add_x_forwarded_for;
                  proxy_set_header        X-Remote-Port        $remote_port;
                  proxy_set_header        X-Forwarded-Proto    $scheme;
                  proxy_redirect          off;
                '';
              };
            };
          };
        };
      };

      # Traffic is passed by nginx reverse proxy
      matrix-synapse = {
        enable = true;
        server_name = "schaeidt.net";
        enable_registration = false;
        database_type = "sqlite3";
        # For simplicity do not reverse-proxy the federation port
        # See https://github.com/matrix-org/synapse#reverse-proxying-the-federation-port
        listeners = [{
          port = 8448;
          bind_address = "";
          type = "http";
          tls = true;
          x_forwarded = false;
          resources = [
            { names = ["federation"]; compress = false; }
          ];
        } {
          port = 8008;
          bind_address = "127.0.0.1";
          type = "http";
          tls = false;
          x_forwarded = true;
          resources = [
            { names = ["client" "webclient"]; compress = true; }
          ];
        }];
      };
    };

    users = {
      extraUsers = { 
        borg = {
          group = "backup";
          isNormalUser = true;
          description = "borg backup user";
          home = "/var/backup";
          openssh.authorizedKeys.keys = [
            "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCv+45uC52OlVJlMpaxdNYjVKMJtM6o0O7FEQ8bogqBk3G0oFhaziGkKFfsiQjIfeJDi3ABZgxdD46Eo7OfOjuoiCqHp4P25CaATqOVALvRf8RVGsjN+rIukH0XewywrGH5aC4gfRatzPJWpFJQm8RMJOtuoH9F8TwEQ2g+DMdbYaJBgDynkwkzH1aZojRcK4V9K0rdEPGC8VRB8T3I9OB0lGXvwLvWNtlfpVocbRM7PkHlw5tkGrhrfOWvpyCNTirnLjqefGazaCOERjS1J6PNuPMCITsDTZpTUizroB/MhZGj+jW0Cs/hlBu0UBUncUuIRXmXMMfM009yKBwYgjyYZXWki6Fugtpc4iS1fcPu/8U65S0WkQGcQSJ1h8L1rz+Lx1C2P37OHToLbBfgCQWVACaPN85yuzaWr/bMZ19sEyuk8evAlCiOvFluaTLbKxMZcRWU/zP4/PcANmc03CvPnbUBTMX83YFM/qp+/2yeHuncRBsgg6BIq3ro+/DstG+9LrrfygqVKbiiaLmO1uEGtFUmREqYHazBTyRLlSusdA/C5mSCO24zMYl9WcQ+81E7t7AN5vqmVOrD1+6Kosez34Q5/n0zBACg93yLpxQTU/2vpzth6fU3a37nzM5lVr7HhUs5uiX3mcs76C7A/gJEbGHsAMxZDSnRc5MILoeJBQ== root@deys"
          ];
        };
      };

      extraGroups.backup = {
        members = [ "borg" ];
      };
    };
    system.stateVersion = "18.03";
  };
}
