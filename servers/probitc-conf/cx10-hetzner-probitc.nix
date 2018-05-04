{
  probitc = {
    deployment.targetEnv = "hetzner";
    deployment.hetzner.mainIPv4 = "88.99.125.175";
    deployment.hetzner.partitions = ''
        clearpart --all --initlabel --drives=sda
        part swap --recommended --label=swap --fstype=swap --ondisk=sda
        part / --fstype=ext4 --fsoptions=noatime,nodiratime,discard --label=root --grow --ondisk=sda
    '';

    networking.hostName = "probitc";
  };
}
