#!/bin/bash
# Copyright (c) 2024 b-data GmbH.
# Distributed under the terms of the MIT License.

set -e

MODULAR_HOME_BAK="$MODULAR_HOME"

# Append the user's modular bin dir to PATH
if [ "$(id -u)" == 0 ] ; then
  if ! grep -q "user's modular bin dir" "/home/$NB_USER${DOMAIN:+@$DOMAIN}/.bashrc"; then
    curl -ssL https://magic.modular.com | grep '^MODULAR_HOME\|^BIN_DIR' \
      > /tmp/magicenv
    . <(sed 's|\$HOME|/home/\$NB_USER\${DOMAIN:+@\$DOMAIN}|g' /tmp/magicenv)
    run_user_group mkdir -p "${BIN_DIR}"
    sed -i 's/\$HOME/\\$HOME/g' /tmp/magicenv
    . /tmp/magicenv
    echo -e "\n# Append the user's modular bin dir to PATH\nif [[ \"\$PATH\" != *\"${BIN_DIR}\"* ]] ; then\n    PATH=\"\$PATH:${BIN_DIR}\"\nfi" >> "/home/$NB_USER${DOMAIN:+@$DOMAIN}/.bashrc"
    rm /tmp/magicenv
  fi
  if ! grep -q "user's modular bin dir" "/home/$NB_USER${DOMAIN:+@$DOMAIN}/.zshrc"; then
    curl -ssL https://magic.modular.com | grep '^MODULAR_HOME\|^BIN_DIR' \
      > /tmp/magicenv
    . <(sed 's|\$HOME|/home/\$NB_USER\${DOMAIN:+@\$DOMAIN}|g' /tmp/magicenv)
    run_user_group mkdir -p "${BIN_DIR}"
    sed -i 's/\$HOME/\\$HOME/g' /tmp/magicenv
    . /tmp/magicenv
    echo -e "\n# Append the user's modular bin dir to PATH\nif [[ \"\$PATH\" != *\"${BIN_DIR}\"* ]] ; then\n    PATH=\"\$PATH:${BIN_DIR}\"\nfi" >> "/home/$NB_USER${DOMAIN:+@$DOMAIN}/.zshrc"
    rm /tmp/magicenv
  fi
else
  if ! grep -q "user's modular bin dir" "$HOME/.bashrc"; then
    curl -ssL https://magic.modular.com | grep '^MODULAR_HOME\|^BIN_DIR' \
      > /tmp/magicenv
    . /tmp/magicenv
    mkdir -p "${BIN_DIR}"
    sed -i 's/\$HOME/\\$HOME/g' /tmp/magicenv
    . /tmp/magicenv
    echo -e "\n# Append the user's modular bin dir to PATH\nif [[ \"\$PATH\" != *\"${BIN_DIR}\"* ]] ; then\n    PATH=\"\$PATH:${BIN_DIR}\"\nfi" >> "$HOME/.bashrc"
    rm /tmp/magicenv
  fi
  if ! grep -q "user's modular bin dir" "$HOME/.zshrc"; then
    curl -ssL https://magic.modular.com | grep '^MODULAR_HOME\|^BIN_DIR' \
      > /tmp/magicenv
    . /tmp/magicenv
    mkdir -p "${BIN_DIR}"
    sed -i 's/\$HOME/\\$HOME/g' /tmp/magicenv
    . /tmp/magicenv
    echo -e "\n# Append the user's modular bin dir to PATH\nif [[ \"\$PATH\" != *\"${BIN_DIR}\"* ]] ; then\n    PATH=\"\$PATH:${BIN_DIR}\"\nfi" >> "$HOME/.zshrc"
    rm /tmp/magicenv
  fi
fi

MODULAR_HOME="$MODULAR_HOME_BAK"
unset MODULAR_HOME_BAK

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

# MAX SDK: Create symlink to /opt/modular
if [ "$(id -u)" == 0 ] ; then
  run_user_group mkdir -p "$extDataDir/magic-data-home/envs"
  run_user_group ln -snf /opt/modular "$extDataDir/magic-data-home/envs/max"
  run_user_group mkdir -p "$extDataDir/versionDone/$sdkVersion"
else
  mkdir -p "$extDataDir/magic-data-home/envs"
  ln -snf /opt/modular "$extDataDir/magic-data-home/envs/max"
  mkdir -p "$extDataDir/versionDone/$sdkVersion"
fi
