#!/bin/bash
# Copyright (c) 2024 b-data GmbH.
# Distributed under the terms of the MIT License.

set -e

# Append the user's pixi bin dir to PATH
if [ "$(id -u)" == 0 ] ; then
  if ! grep -q "user's pixi bin dir" "/home/$NB_USER${DOMAIN:+@$DOMAIN}/.bashrc"; then
    run_user_group mkdir -p "${HOME}/.pixi/bin"
    echo -e "\n# Append the user's pixi bin dir to PATH\nif [[ \"\$PATH\" != *\"\$HOME/.pixi/bin\"* ]] ; then\n    PATH=\"\$PATH:\$HOME/.pixi/bin\"\nfi" >> "/home/$NB_USER${DOMAIN:+@$DOMAIN}/.bashrc"
  fi
  if ! grep -q "user's pixi bin dir" "/home/$NB_USER${DOMAIN:+@$DOMAIN}/.zshrc"; then
    run_user_group mkdir -p "${HOME}/.pixi/bin"
    echo -e "\n# Append the user's pixi bin dir to PATH\nif [[ \"\$PATH\" != *\"\$HOME/.pixi/bin\"* ]] ; then\n    PATH=\"\$PATH:\$HOME/.pixi/bin\"\nfi" >> "/home/$NB_USER${DOMAIN:+@$DOMAIN}/.zshrc"
  fi
else
  if ! grep -q "user's pixi bin dir" "$HOME/.bashrc"; then
    mkdir -p "${HOME}/.pixi/bin"
    echo -e "\n# Append the user's pixi bin dir to PATH\nif [[ \"\$PATH\" != *\"\$HOME/.pixi/bin\"* ]] ; then\n    PATH=\"\$PATH:\$HOME/.pixi/bin\"\nfi" >> "$HOME/.bashrc"
  fi
  if ! grep -q "user's pixi bin dir" "$HOME/.zshrc"; then
    mkdir -p "${HOME}/.pixi/bin"
    echo -e "\n# Append the user's pixi bin dir to PATH\nif [[ \"\$PATH\" != *\"\$HOME/.pixi/bin\"* ]] ; then\n    PATH=\"\$PATH:\$HOME/.pixi/bin\"\nfi" >> "$HOME/.zshrc"
  fi
fi

# MAX SDK: Evaluate and set version
if [ "$(id -u)" == 0 ] ; then
  if [ "${MOJO_VERSION}" = "nightly" ]; then
    extDataDir=/home/$NB_USER${DOMAIN:+@$DOMAIN}/.local/share/code-server/User/globalStorage/modular-mojotools.vscode-mojo-nightly
    sdkVersion=$(jq -r '.sdkVersion' /opt/code-server/lib/vscode/extensions/modular-mojotools.vscode-mojo*/package.json)
  else
    extDataDir=/home/$NB_USER${DOMAIN:+@$DOMAIN}/.local/share/code-server/User/globalStorage/modular-mojotools.vscode-mojo
    sdkVersion=$MOJO_VERSION
  fi
else
  if [ "${MOJO_VERSION}" = "nightly" ]; then
    extDataDir=$HOME/.local/share/code-server/User/globalStorage/modular-mojotools.vscode-mojo-nightly
    sdkVersion=$(jq -r '.sdkVersion' /opt/code-server/lib/vscode/extensions/modular-mojotools.vscode-mojo*/package.json)
  else
    extDataDir=$HOME/.local/share/code-server/User/globalStorage/modular-mojotools.vscode-mojo
    sdkVersion=$MOJO_VERSION
  fi
fi

# MAX SDK: Create symlink to /usr/local
if [ "$(id -u)" == 0 ] ; then
  run_user_group mkdir -p "$extDataDir/magic-data-home/envs"
  run_user_group ln -snf /usr/local "$extDataDir/magic-data-home/envs/max"
  run_user_group mkdir -p "$extDataDir/versionDone/$sdkVersion"
else
  mkdir -p "$extDataDir/magic-data-home/envs"
  ln -snf /usr/local "$extDataDir/magic-data-home/envs/max"
  mkdir -p "$extDataDir/versionDone/$sdkVersion"
fi
