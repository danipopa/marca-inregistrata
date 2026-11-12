#!/usr/bin/env bash
set -euo pipefail

# Keep this terminal open while using the website or running Rails locally.
forwards=(-L "${DEV_MYSQL_PORT:-13306}:127.0.0.1:13306")
if [[ "${DEV_FORWARD_WEB:-true}" == true ]]; then
  forwards+=(-L "${DEV_WEB_PORT:-18080}:192.168.100.15:30081")
fi
exec ssh -p "${DEV_SSH_PORT:-22122}" \
  -o ExitOnForwardFailure=yes \
  -o ServerAliveInterval=30 \
  "${forwards[@]}" \
  "${DEV_SSH_HOST:-root@10.0.0.250}" \
  bash -s <<'REMOTE'
set -euo pipefail
forward_pattern='^kubectl -n inregistrare-marca port-forward --address 127.0.0.1 service/marca-mysql 13306:3306$'
remote_port_open() {
  timeout 2 bash -c 'exec 3<>/dev/tcp/127.0.0.1/13306' 2>/dev/null
}
existing_forward=$(pgrep -o -f "$forward_pattern" || true)
if [[ -n "$existing_forward" ]]; then
  # A live kubectl PID can outlast its listener. Allow startup to finish before
  # replacing a stale forward, then keep watching a reused listener as well.
  for ((attempt = 0; attempt < 5; attempt++)); do
    remote_port_open && break
    sleep 1
  done
  if remote_port_open; then
    echo 'Reusing the existing tux1 MySQL port-forward. Keep this terminal open.'
    while kill -0 "$existing_forward" 2>/dev/null && remote_port_open; do sleep 2; done
  fi
  if kill -0 "$existing_forward" 2>/dev/null; then
    echo 'Restarting the stale tux1 MySQL port-forward.'
    # Recheck the command before signalling a PID discovered earlier.
    if pgrep -f "$forward_pattern" | /bin/grep -qx "$existing_forward"; then
      kill "$existing_forward"
      for ((attempt = 0; attempt < 20; attempt++)); do
        remote_port_open || break
        sleep 0.1
      done
    fi
  fi
fi
exec kubectl -n inregistrare-marca port-forward --address 127.0.0.1 service/marca-mysql 13306:3306
REMOTE
