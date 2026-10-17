#!/usr/bin/env bash
set -euo pipefail

# Keep this terminal open while using the website or running Rails locally.
exec ssh -p "${DEV_SSH_PORT:-22122}" \
  -o ExitOnForwardFailure=yes \
  -o ServerAliveInterval=30 \
  -L "${DEV_MYSQL_PORT:-13306}:127.0.0.1:13306" \
  -L "${DEV_WEB_PORT:-18080}:192.168.100.15:30081" \
  "${DEV_SSH_HOST:-root@10.0.0.250}" \
  'existing_forward=$(pgrep -o -f "^kubectl -n inregistrare-marca port-forward --address 127.0.0.1 service/marca-mysql 13306:3306$" || true)
   if [ -n "$existing_forward" ]; then
     echo "Reusing the existing tux1 MySQL port-forward. Keep this terminal open."
     while kill -0 "$existing_forward" 2>/dev/null; do sleep 2; done
   fi
   exec kubectl -n inregistrare-marca port-forward --address 127.0.0.1 service/marca-mysql 13306:3306'
