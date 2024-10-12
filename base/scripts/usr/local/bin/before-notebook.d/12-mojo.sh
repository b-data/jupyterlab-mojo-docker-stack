#!/bin/bash
# Copyright (c) 2020 b-data GmbH.
# Distributed under the terms of the MIT License.

set -e

# MAX SDK: Evaluate and set version
if [ "${MOJO_VERSION}" = "nightly" ]; then
  extDataDir=/home/$NB_USER${DOMAIN:+@$DOMAIN}/.local/share/code-server/User/globalStorage/modular-mojotools.vscode-mojo-nightly
  sdkVersion=$(jq -r '.sdkVersion' /opt/code-server/lib/vscode/extensions/modular-mojotools.vscode-mojo*/package.json)
else
  extDataDir=/home/$NB_USER${DOMAIN:+@$DOMAIN}/.local/share/code-server/User/globalStorage/modular-mojotools.vscode-mojo
  sdkVersion=$MOJO_VERSION
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
