#!/usr/bin/env bash
set -euo pipefail
set +m
if ((BASH_VERSINFO[0] < 4 || (BASH_VERSINFO[0] == 4 && BASH_VERSINFO[1] < 4))); then
  echo 'This script requires Bash 4.4 or later.' >&2
  exit 1
fi

PROJECT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
API_PORT="${DEV_API_PORT:-3001}"
WEB_PORT="${DEV_WEB_PORT:-3000}"
MYSQL_PORT="${DEV_MYSQL_PORT:-13306}"
configure=false

for argument in "$@"; do
  case "$argument" in
    --configure) configure=true ;;
    -h|--help)
      cat <<'HELP'
Usage: ./dev.sh [--configure]

Start the tux1 MySQL tunnel, Rails API and Nuxt frontend. Ctrl+C stops the
processes started by this script; an existing database tunnel is left running.

--configure  Refresh ignored api/.env.local from the development cluster.

Defaults: website http://localhost:3000, API http://localhost:3001, MySQL 13306.
Override DEV_WEB_PORT, DEV_API_PORT, DEV_MYSQL_PORT, DEV_SSH_HOST or DEV_SSH_PORT.
Requires Ruby/Bundler, Node/npm, SSH and Linux setsid. Install app dependencies
with (cd api && bundle install) and (cd web && npm install) before first use.
HELP
      exit 0 ;;
    *) echo "Unknown argument: $argument. Use --help." >&2; exit 1 ;;
  esac
done

for command in ruby bundle npm ssh setsid; do
  command -v "$command" >/dev/null || { echo "Missing command: $command" >&2; exit 1; }
done
for port in "$API_PORT" "$WEB_PORT" "$MYSQL_PORT"; do
  if [[ ! "$port" =~ ^[0-9]{1,5}$ ]] || ((10#$port < 1 || 10#$port > 65535)); then
    echo "Invalid development port: $port" >&2
    exit 1
  fi
done
API_PORT=$((10#$API_PORT))
WEB_PORT=$((10#$WEB_PORT))
MYSQL_PORT=$((10#$MYSQL_PORT))
if [[ "$API_PORT" == "$WEB_PORT" || "$API_PORT" == "$MYSQL_PORT" || "$WEB_PORT" == "$MYSQL_PORT" ]]; then
  echo 'API, frontend and MySQL must use different ports.' >&2
  exit 1
fi

port_open() {
  ruby -rsocket -e 'begin; Socket.tcp("127.0.0.1", ARGV.fetch(0).to_i, connect_timeout: 0.5).close; rescue SystemCallError, IOError; exit 1; end' "$1" 2>/dev/null
}

mysql_ready() {
  ruby -rsocket -rtimeout -e '
    begin
      Timeout.timeout(2) do
        Socket.tcp("127.0.0.1", ARGV.fetch(0).to_i, connect_timeout: 0.5) do |socket|
          header = socket.read(4)
          exit 1 unless header && header.bytesize == 4
          # MySQL starts its greeting packet with protocol version 10.
          exit(socket.read(1) == "\x0a" ? 0 : 1)
        end
      end
    rescue SystemCallError, IOError, Timeout::Error
      exit 1
    end
  ' "$1" 2>/dev/null
}

for port in "$API_PORT" "$WEB_PORT"; do
  if port_open "$port"; then
    echo "Port $port is already in use. Stop that server or choose DEV_API_PORT / DEV_WEB_PORT." >&2
    exit 1
  fi
done
[[ -x "$PROJECT_DIR/web/node_modules/.bin/nuxt" ]] || { echo 'Run: cd web && npm install' >&2; exit 1; }
(cd "$PROJECT_DIR/api" && bundle check >/dev/null) || { echo 'Run: cd api && bundle install' >&2; exit 1; }

export DEV_MYSQL_PORT="$MYSQL_PORT"
if [[ "$configure" == true || ! -f "$PROJECT_DIR/api/.env.local" ]]; then
  bash "$PROJECT_DIR/deploy/development/rails.sh" --configure
fi
export RAILS_ENV=development
export DATABASE_ADAPTER=mysql2 DATABASE_HOST=127.0.0.1 DATABASE_PORT="$MYSQL_PORT"
export DATABASE_NAME=marca_inregistrata_production DATABASE_USERNAME=marca
unset DATABASE_URL

children=()
cleanup() {
  trap - EXIT INT TERM
  if ((${#children[@]} == 0)); then return; fi
  printf '\nStopping development services...\n'
  for pid in "${children[@]}"; do kill -TERM -- "-$pid" 2>/dev/null || true; done
  for ((attempt = 0; attempt < 30; attempt++)); do
    running=false
    for pid in "${children[@]}"; do
      if kill -0 -- "-$pid" 2>/dev/null; then running=true; fi
    done
    [[ "$running" == true ]] || break
    sleep 0.1
  done
  for pid in "${children[@]}"; do kill -KILL -- "-$pid" 2>/dev/null || true; done
  wait "${children[@]}" 2>/dev/null || true
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

start_service() {
  local directory="$1"
  shift
  (cd "$directory" && exec setsid "$@") &
  last_pid=$!
  children+=("$last_pid")
}

wait_for_port() {
  local port="$1" pid="$2" service="$3" deadline=$((SECONDS + 30))
  until port_open "$port"; do
    if [[ -n "$pid" ]] && ! kill -0 "$pid" 2>/dev/null; then
      echo "$service exited before becoming ready. See the output above." >&2
      return 1
    fi
    if ((SECONDS >= deadline)); then
      echo "Timed out waiting for $service on port $port." >&2
      return 1
    fi
    sleep 0.5
  done
}

if port_open "$MYSQL_PORT"; then
  echo "Reusing the existing database tunnel on 127.0.0.1:$MYSQL_PORT."
else
  echo 'Starting the development database tunnel...'
  start_service "$PROJECT_DIR" env DEV_FORWARD_WEB=false bash deploy/development/tunnel.sh
  wait_for_port "$MYSQL_PORT" "$last_pid" 'MySQL tunnel'
fi

echo 'Waiting for MySQL through the development tunnel...'
deadline=$((SECONDS + 30))
until mysql_ready "$MYSQL_PORT"; do
  if ((SECONDS >= deadline)); then
    echo 'MySQL did not respond through the tunnel. Check the remote marca-mysql pod and restart deploy/development/tunnel.sh; --configure only refreshes credentials.' >&2
    exit 1
  fi
  sleep 0.5
done

# Check credentials against the development database without running migrations.
echo 'Checking the development database connection...'
(cd "$PROJECT_DIR/api" && bin/rails db:version) || {
  echo 'Database connection failed. Check the tunnel and try ./dev.sh --configure.' >&2
  exit 1
}

mkdir -p "$PROJECT_DIR/api/tmp/pids"
start_service "$PROJECT_DIR/api" bin/rails server -b 127.0.0.1 -p "$API_PORT" -P "tmp/pids/dev-$API_PORT.pid"
wait_for_port "$API_PORT" "$last_pid" 'Rails API'

start_service "$PROJECT_DIR/web" env \
  NUXT_PUBLIC_API_BASE_URL="http://localhost:$API_PORT" \
  NUXT_PUBLIC_ANALYTICS_PROVIDER=none NUXT_PUBLIC_GOOGLE_ANALYTICS_ID= \
  NUXT_PUBLIC_SITE_INDEXABLE=false \
  npm run dev -- --host 127.0.0.1 --port "$WEB_PORT"
wait_for_port "$WEB_PORT" "$last_pid" 'Nuxt frontend'

printf '\nWebsite: http://localhost:%s\nAPI:     http://localhost:%s\nPress Ctrl+C to stop.\n\n' "$WEB_PORT" "$API_PORT"
status=0
wait -n "${children[@]}" || status=$?
echo 'A development service stopped; shutting down the other services.' >&2
exit "$status"
