# bash on nixos is not supported by gitlab-runner
https://gitlab.com/gitlab-org/gitlab-ci-multi-runner/blob/master/shells/bash.go#L16

# usage

```
nixops create -d shell-runner ./vbox-shell-runner.nix ./vbox-runner.nix
nixops ssh -d shell-runner shell-runner # machine name is defined in *.nix files
```