# deys

to activate the system in one shot run

```
./activate.sh

# then for example
nixos-rebuild switch
```

what this script does is symlinking all files in this directory to the appropriate target location.
 the mapping can be seen as following:


maps recursively
-- `./home` -> `/home/$USER`
-- `./configuration.nix` -> `/etc/nixos/configuration.nix`
