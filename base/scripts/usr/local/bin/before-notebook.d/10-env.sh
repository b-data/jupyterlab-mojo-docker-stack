#!/bin/bash
# Copyright (c) 2020 b-data GmbH.
# Distributed under the terms of the MIT License.

set -e

# Set defaults for environment variables in case they are undefined
LANG=${LANG:=en_US.UTF-8}
TZ=${TZ:=Etc/UTC}

# Info about timezone
_log "TZ is set to $TZ (/etc/localtime and /etc/timezone remain unchanged)"

if [ "$(id -u)" == 0 ] ; then
  # Add/Update locale if requested
  if [ -n "$LANGS" ]; then
    for i in $LANGS; do
      sed -i "s/# $i/$i/g" /etc/locale.gen
    done
  fi
  if [ "$LANG" != "en_US.UTF-8" ]; then
    sed -i "s/# $LANG/$LANG/g" /etc/locale.gen
  fi
  if [[ "$LANG" != "en_US.UTF-8" || -n "$LANGS" ]]; then
    locale-gen --keep-existing
  fi
  update-locale --reset LANG="$LANG"
  # Info about locale
  _log "LANG is set to $LANG"
else
  # Warn if the user wants to add locales but hasn't started the container as
  # root.
  if [ -n "$LANGS" ]; then
    _log "WARNING: Container must be started as root to add locale(s)!"
  fi
  # Warn if the user wants to change to a locale that is not available.
  if ! grep -v '^#' < /etc/locale.gen | grep -q "$LANG"; then
    _log "WARNING: Locale $LANG is not available!"
    . /etc/default/locale
    _log "WARNING: Resetting LANG to $LANG"
  else
    # Info about locale
    _log "LANG is set to $LANG"
  fi
fi
