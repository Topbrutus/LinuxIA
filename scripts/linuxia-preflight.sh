#!/usr/bin/env bash
set -euo pipefail

test -d /opt/linuxia/.git

systemctl is-enabled linuxia-configsnap.timer >/dev/null

findmnt -T /opt/linuxia/data/shareA >/dev/null
findmnt -T /opt/linuxia/data/shareB >/dev/null

DIR="/opt/linuxia/data/shareA/archives/configsnap"

if [ "$(id -u)" -eq 0 ]; then
  install -d -m 0775 -o gaby -g users "$DIR"
fi

test -d "$DIR"
test -w "$DIR"
