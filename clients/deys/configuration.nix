{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      # The hardware is not versioned because it is generated.
      /etc/nixos/hardware-configuration.nix
    ];

  boot = {
    initrd.luks.devices = [
      {
        name = "cryptovg";
        device = "/dev/sda2";
        preLVM = true;
        allowDiscards = true;
      }
    ];
    loader.grub = {
      enable = true;
      version = 2;
      device = "/dev/sda";
      enableCryptodisk = true;
      memtest86.enable = true;
    };
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };

  powerManagement.enable = true;

  hardware.pulseaudio = {
    enable = true;
    package = pkgs.pulseaudioFull;
  };

  fonts = {
    enableFontDir = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
      corefonts
      vistafonts
      inconsolata
      terminus_font
      proggyfonts
      dejavu_fonts
      font-awesome-ttf
      ubuntu_font_family
      source-code-pro
      source-sans-pro
      source-serif-pro
    ];
  };

  networking = {
    hostName = "deys";
    # Unfortunately AirVPN only works on v4
    enableIPv6 = false;
    wireless = {
      enable = true;
      interfaces = [ "wlp4s0" ];
      userControlled.enable = true;
      userControlled.group = "wheel";
    };
  };

  # Select internationalisation properties.
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "de";
    defaultLocale = "en_US.UTF-8";
  };

  environment = {
    variables.EDITOR="vim";
    pathsToLink = [ "/etc/gconf" ];
  };

  time.timeZone = "Europe/Berlin";

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    # The usual stuff t
    wget
    curl
    netcat-openbsd
    htop
    atop
    iotop
    strace
    manpages
    bashCompletion
    zsh
    rcm
    gnupg1compat
    gnupg
    pwgen
    ncdu
    mosh
    vim
    lsof
    xclip

    # networking tools
    tcpdump
    mtr
    wireshark
    ndisc6
    iftop
    jnettop
    bind
    lftp
    whois
    autossh
    nmap
    update-resolv-conf

    # X applications and related tools
    i3
    i3status
    i3lock
    rxvt_unicode-with-plugins
    dmenu
    gitAndTools.gitFull
    xorg.xrandr
    haskellPackages.xmobar
    xlibs.xkill
    xcalib
    wpa_supplicant_gui
    clawsMail
    firefox
    gnome3.gedit
    x11_ssh_askpass
    chromium
    slock

    # audio / media
    paprefs
    pavucontrol
    mplayer
    mpv
    scrot
    imagemagick
    vlc
    pinta
    evince

    # system foo
    acpi
    acpitool
    bridge-utils
    unzip
    file
    sudo
    lxc
    which
    progress
    pmount
    xorg.xbacklight
    libfaketime

    # dev tools
    vagrant
    silver-searcher
    tig
    fzf
    gist
    vscode

    # admin tools
    tightvnc
    virtmanager
    libressl
    nixops
    mkpasswd
    sslscan
    testdisk

    # misc
    physlock
    gnome3.dconf
    iptables
    pass
    borgbackup
  ];

  # backup-all service collects all user modified data
  # the backup service is started once per hour by a systemd timer declared below
  #
  # > The root ssh key is registered on the target in the for the backup user.
  #   @see repo file `servers/probitc-conf/probitc.nix`
  # > Following environment variables are set in the `.config/bash/environment`
  #   export BORG_REPOSITORY='user@host:root@hostname.local'
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
        $BORG_REPOSITORY::'{hostname}-{now:%Y-%m-%d_%H-%M}' \
        / \
        --exclude '/home/*/.cache' \
        --exclude '/home/*/.compose-cache' \
        --exclude 're:^/home/.*/node_modules/' \
        --exclude '/dev' \
        --exclude '/nix' \
        --exclude '/tmp' \
        --exclude '/mnt' \
        --exclude '/proc' \
        --exclude '/sys'

      # Use the `prune` subcommand to maintain 24 hourly, 7 daily, 4 weekly and 6 monthly
      ${pkgs.borgbackup}/bin/borg prune -v --list $BORG_REPOSITORY --prefix '{hostname}-' \
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

  # Per user backup service
  # To enable for the active user `systemctl --user enable backup`
  systemd.user.services.backup = {
    description = "Backup the user %i";
    path = [ pkgs.borgbackup pkgs.openssh ];
    script = ''
        source /home/%i/.config/bash/environment

        ${pkgs.borgbackup}/bin/borg create -v --stats                          \
          $REPOSITORY::'{hostname}-{now:%Y-%m-%d_%H-%M}' \
          /home/%i                                       \
          --exclude '/home/%i/.cache'                    \
          --exclude '/home/%i/.compose-cache'

        ${pkgs.borgbackup}/bin/borg prune -v --list $REPOSITORY --prefix '{hostname}-' \
          --keep-hourly=24 --keep-daily=7 --keep-weekly=4 --keep-monthly=6
      '';
  };

  # Timer job for per user backup services
  systemd.user.timers.backup = {
    description = "Update timer for locate database";
    partOf      = [ "backup.service" ];
    wantedBy    = [ "timers.target" ];
    timerConfig.OnCalendar = "hourly";
  };

  # List services that you want to enable:
  services = {
    openssh.enable = true;
    thermald.enable = true;

    tlp = {
      enable = true;
      extraConfig = ''
        START_CHARGE_THRESH_BAT0=75
        STOP_CHARGE_THRESH_BAT0=90

        START_CHARGE_THRESH_BAT1=75
        STOP_CHARGE_THRESH_BAT1=90
      '';
    };
    printing.enable = true;

    xserver = {
      startDbusSession = true;
      enable = true; 
      layout = "de";
      xkbOptions = "eurosign:e";
      synaptics = {
        enable = true;
        twoFingerScroll = true;
      };
      windowManager = {
        xmonad = {
          enable = true;
          enableContribAndExtras = true;
        };
      };
    };

    redshift = {
      enable = true;
      latitude = "48";
      longitude = "11";
      temperature = {
        day = 3500;
        night = 3500;
      };
      brightness = {
        day = "1.0";
        night = "0.7";
      };
    };

    openvpn = {
      servers = {
        airvpn = {
          autoStart = true;
          config = ''
            # --------------------------------------------------------
            # Air VPN | https://airvpn.org | Monday 15th of May 2017 07:15:52 PM
            # OpenVPN Client Configuration
            # AirVPN_Germany_UDP-443
            # --------------------------------------------------------

            client
            dev tun
            proto udp
            remote de.vpn.airdns.org 443
            resolv-retry infinite
            nobind
            persist-key
            persist-tun
            remote-cert-tls server
            cipher AES-256-CBC
            comp-lzo no
            route-delay 5
            verb 3
            explicit-exit-notify 5
            ca /home/hschaeidt/Documents/vpn/airvpn/ca.crt
            cert /home/hschaeidt/Documents/vpn/airvpn/cert.crt
            key /home/hschaeidt/Documents/vpn/airvpn/key.key
            key-direction 1
            tls-auth /home/hschaeidt/Documents/vpn/airvpn/ta.key
          '';
          updateResolvConf = true;
        };
      };
    };
  };

  programs.zsh.enable = true;
  users = {
    extraUsers.hschaeidt = {
      isNormalUser = true;
      initialPassword = "fnordkuchen!";
      uid = 1000;
      extraGroups = [ "wheel" "audio" "libvirtd" ];
      shell = pkgs.zsh;
    };
    extraUsers.root = {
      subGidRanges = [ { count = 65536; startGid = 1000000; } ];
      subUidRanges = [ { count = 65536; startUid = 1000000; } ];
    };
  };

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "17.03";
}
