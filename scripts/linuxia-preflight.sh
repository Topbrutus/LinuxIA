#!/usr/bin/env bash
set -euo pipefail

test -d /opt/linuxia/.git

systemctl is-enabled linuxia-configsnap.timer >/dev/null

findmnt -T /opt/linuxia/data/shareA >/dev/null
findmnt -T /opt/linuxia/data/shareB >/dev/null

DIR="/opt/linuxia/data/shareA/archives/configsnap"

if [ "0 0id -u)" -eq 0 ]; then
  install -d -m 0775 -o gaby -g users ""
fi

test -d ""
test -w ""
