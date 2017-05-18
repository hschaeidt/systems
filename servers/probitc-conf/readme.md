# probitc

the name is a mystery even to me now. when i decided on it, it actually had some meaning...

## job

- backup server for my clients

## hacking

```bash
# creating/deploying
nixops create -d probitc ./cx10-hetzner-probitc.nix ./probitc.nix
nixops deploy -d probitc

# can be useful sometimes
nixops ssh -d probitc probitc # where first is the deployment name and second the machine name defined in *.nix file
```
