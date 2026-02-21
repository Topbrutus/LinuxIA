#!/usr/bin/env bash
set -euo pipefail

ASK="$(mktemp /run/linuxia-askpass.XXXXXX)"
cleanup(){ rm -f "$ASK"; }
trap cleanup EXIT

cat >"$ASK" <<'EOS'
#!/bin/sh
case "$1" in
  *Username*) echo "x-access-token" ;;
  *Password*) systemd-creds decrypt /etc/linuxia/creds/github_token.cred - ;;
  *) echo ;;
esac
EOS

chmod 700 "$ASK"
export GIT_ASKPASS="$ASK"
export GIT_TERMINAL_PROMPT=0

exec /opt/linuxia/scripts/linuxia-git-push.sh
