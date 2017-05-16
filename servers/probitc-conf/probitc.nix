{
  network.description = "probitc";

  probitc = { config, pkgs, ... }:
  {
    environment.systemPackages = with pkgs; [
      borgbackup
    ];

    users = {
      extraUsers.backup = {
        isNormalUser = true;
        uid = 1001;
        extraGroups = [ "backup" ];
        openssh.authorizedKeys.keys = [ 
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCv+45uC52OlVJlMpaxdNYjVKMJtM6o0O7FEQ8bogqBk3G0oFhaziGkKFfsiQjIfeJDi3ABZgxdD46Eo7OfOjuoiCqHp4P25CaATqOVALvRf8RVGsjN+rIukH0XewywrGH5aC4gfRatzPJWpFJQm8RMJOtuoH9F8TwEQ2g+DMdbYaJBgDynkwkzH1aZojRcK4V9K0rdEPGC8VRB8T3I9OB0lGXvwLvWNtlfpVocbRM7PkHlw5tkGrhrfOWvpyCNTirnLjqefGazaCOERjS1J6PNuPMCITsDTZpTUizroB/MhZGj+jW0Cs/hlBu0UBUncUuIRXmXMMfM009yKBwYgjyYZXWki6Fugtpc4iS1fcPu/8U65S0WkQGcQSJ1h8L1rz+Lx1C2P37OHToLbBfgCQWVACaPN85yuzaWr/bMZ19sEyuk8evAlCiOvFluaTLbKxMZcRWU/zP4/PcANmc03CvPnbUBTMX83YFM/qp+/2yeHuncRBsgg6BIq3ro+/DstG+9LrrfygqVKbiiaLmO1uEGtFUmREqYHazBTyRLlSusdA/C5mSCO24zMYl9WcQ+81E7t7AN5vqmVOrD1+6Kosez34Q5/n0zBACg93yLpxQTU/2vpzth6fU3a37nzM5lVr7HhUs5uiX3mcs76C7A/gJEbGHsAMxZDSnRc5MILoeJBQ== root@deys"
        ];
      };

      extraGroups.backup = {
        gid = 1002;
        members = [ "backup" ];
      };
    };
  };
}
