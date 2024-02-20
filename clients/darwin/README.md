# Hendriks (Darwin) system flake

## Setup

- Install [nix](https://nixos.org/download.html#nix-install-macos) for MacOS, I am using the recommend multi-user installation
- Follow the flake instructions from [nix-darwin](https://github.com/LnL7/nix-darwin?tab=readme-ov-file#flakes) to setup nix-darwin
- Follow the flake instructions from [home-manager](https://nix-community.github.io/home-manager/index.xhtml#sec-flakes-nix-darwin-module) for nix-darwin

## Caveats & Troubleshooting

The nix ecosystem shines especially when it comes to foggy and unclear error messages, especially for newcomers. Getting started with nix might seem so easy and smooth, until eventually running into the first issue while rebuilding the configuration.

This is not a classic "Troubleshooting" section, but more of a trial & error section of issues I was having and how I managed to fix them.

### Custom hostname in ~/.config/nix-darwin

The documentation from the [flakes section](https://github.com/LnL7/nix-darwin?tab=readme-ov-file#flakes) recommends that a system rebuild has to be done by using:

```bash
darwin-rebuild switch --flake ~/.config/nix-darwin
```

For those who have previously used flakes, this might look odd at a first glance, because we didn't specify a flake attribute to build using the `#` suffix. In my example this would have been `#yBookPro`. As a reference the full command:

```bash
darwin-rebuild switch --flake ~/.config/nix-darwin#yBookPro
```

What the documentation does not tell us, is that the `darwin-rebuild` command will [automatically use your Macs hostname](https://github.com/LnL7/nix-darwin/blob/0e6857fa1d632637488666c08e7b02c08e3178f8/pkgs/nix-tools/darwin-rebuild.sh#L143) as defined in `Settings -> General -> Details -> Name` and use it as an flake attribute for the configuration to be built, if none has been specified by the user.

This is why it is **super important**, that your darwin configuration name must match your systems hostname (for convinience):

```nix
darwinConfigurations."<YOUR HOSTNAME HERE>" = nix-darwin.lib.darwinSystem {
...
}
```

### Properly setting up home-manager

While setting up home-manager seems pretty straight forward, I was running into one issue where home directories of my user where conflicting:

```
error:
       … while evaluating the attribute 'value'

         at /nix/store/lij1v3njrvp0n5qzvamh4r5i9588csq9-source/lib/modules.nix:809:9:

          808|     in warnDeprecation opt //
          809|       { value = builtins.addErrorContext "while evaluating the option `${showOption loc}':" value;
             |         ^
          810|         inherit (res.defsFinal') highestPrio;

       … while calling the 'addErrorContext' builtin

         at /nix/store/lij1v3njrvp0n5qzvamh4r5i9588csq9-source/lib/modules.nix:809:17:

          808|     in warnDeprecation opt //
          809|       { value = builtins.addErrorContext "while evaluating the option `${showOption loc}':" value;
             |                 ^
          810|         inherit (res.defsFinal') highestPrio;

       (stack trace truncated; use '--show-trace' to show the full trace)

       error: The option `home-manager.users.hschaeidt.home.homeDirectory' has conflicting definition values:
       - In `<unknown-file>': "/Users/hschaeidt"
       - In `/nix/store/r5m3b8jhx9dkllqr9lhlba7jnn9i56gs-source/nixos/common.nix': "/var/empty"
```

This error message is produced as a result, if in the home-manager configuration the home directory is set to "/Users/<USERNAME>", but the user hasn't been defined in the darwin configuration yet. However it's not the error message telling you what to do in order to fix this. So let's have a look at this together, what do we have here and how does it differ from a classic NixOS setup.

First of all, when running a declarative OS like NixOS, all users are also defined in the global `/etc/nixos/configuration.nix`. There is no implicit user creation process like we do have on MacOS. Let's say we are running a NixOS and we haven't any user defined in our `configuration.nix`. The result after a rebuild would be that there is no user to login with except the root user, simply said.

The reason why this is different here and why it still works is following: MacOS itself is not fully managed by nix-darwin. All the initial setup, the updates, and the other important system parts are still being managed by MacOS itself, right? So the user we are currently running on our system wasn't created by `nix-darwin`, but already existed when we decided to setup nix-darwin on our machine.

It might sound stupid, when reasoning about it like that, but now what we have to ensure is the exact opposite from what we are supposed to do in a declarative OS. We have to make sure that the user defined in our configuration **matches the user that already exists on our system**. Sure, nix-darwin would still work without this information, home-manager however needs this information in order to work properly.

So we add the following into our nix-darwin configuration to fix this issue:

```nix
users.users.hschaeidt = {
    home = "/Users/hschaeidt";
};
```

And then in our home-manager section:

```nix
home.username = "hschaeidt";
home.homeDirectory = "/Users/hschaeidt";
```

Do a rebuild and home-manager is set up now.
