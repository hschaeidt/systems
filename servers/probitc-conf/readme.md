# probitc

the name is a mystery even to me now. when i decided on it, it actually had some meaning...

## job

- backup server for my clients

## configuration

### hetzner

the server is currently hosted on a small hetzner.de vserver (cx10). the relevant configuration - including the
 hostname - is defined in the [cx10-hetzner-probitc.nix](./cx10-hetzner-probitc.nix).


the machine configuration itself is defined in the [probitc.nix](./probitc.nix) file.


### backup (borgbackup.org)

to avoid any data loss, a custom systemd job is running and taking care of the file system backups, excluding the nix-store and any other non-relevant system-parts.


if the machine is created, started and provisioned for the first time, a few manual set-up jobs are required.

* run the `borg init user@host:root@hostname.local` command as root.
```bash
todo: add real command here
```
* create a file to store environment variables. the systemd service automatically loads the `/root/.config/bash/environment` file. alternatively they can be set in /root/.profile for example.
```bash
export BORG_PASSPHRASE='i am going to cipher them all now then decipher them' # choose a long and random passphrase
export SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/ssh-agent                               # the job will need the ssh-agent to access the backup key
export BORG_REPOSITORY='borg@schaeidt.net:root@probitc.local'                 # the backup repository
```

## hacking

```bash
# creating/deploying
nixops create -d probitc ./cx10-hetzner-probitc.nix ./probitc.nix
nixops deploy -d probitc

# can be useful sometimes
nixops ssh -d probitc probitc # where first is the deployment name and second the machine name defined in *.nix file
```
