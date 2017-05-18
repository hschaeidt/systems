#!/bin/sh

echo "Symlinking /etc/nixos/configuration.nix"
CONFIGURATION_FILE="/etc/nixos/configuration.nix"
# Backup existing configuration file
if [ -e $CONFIGURATION_FILE ]; then
  sudo mv "$CONFIGURATION_FILE" "$CONFIGURATION_FILE.backup"
fi

# Link new configuration file
sudo ln -s $(pwd -P)/configuration.nix $CONFIGURATION_FILE
echo "Symlinked $(pwd -P)/configuration.nix to $CONFIGURATION_FILE"

# Clean home folder
echo "Removing home files that will be symlinked"

REPO_HOME_PATH=$(pwd)/home
REPO_HOME_PATH_SUBSTR_LENGTH=${#REPO_HOME_PATH}

# Creates recursively symlinks from ./home to the currents user home folder
# Use carefully as it deletes files that might get overriden
function symlink_folder {
  for filename in $1/{.,}*; do
    if [ -e $filename ]; then
      # As the call might be recursive, here we have to make sure to always substring REPO_HOME_PATH
      # to maintain subfolder structures
      # Otherwise $(basename $filename) would have been fine
      BASE_NAME=${filename:REPO_HOME_PATH_SUBSTR_LENGTH}
      TARGET_NAME=/home/$USER$BASE_NAME

      # Skip dot directory...
      if [ "." == $(basename $filename) ]; then
        continue
      fi
      # Skip double dot directory...
      if [ ".." == $(basename $filename) ]; then
        continue
      fi

      if [ -d $filename ]; then
        if ! [ -d $TARGET_NAME ]; then
          echo "Creating sub directory: $filename"
          mkdir $TARGET_NAME
        fi

        symlink_folder $filename
        continue
      fi

      echo "Removing target file: $TARGET_NAME"
      rm $TARGET_NAME
      echo "Symlinking $filename to $TARGET_NAME"
      ln -s $filename $TARGET_NAME
    fi
  done
}

symlink_folder $REPO_HOME_PATH
