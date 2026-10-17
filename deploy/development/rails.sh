#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../../api"

# Read only the development API's credentials; never print them to the terminal.
DEV_API_SECRET_JSON="$(ssh -p "${DEV_SSH_PORT:-22122}" \
  "${DEV_SSH_HOST:-root@10.0.0.250}" \
  'kubectl -n inregistrare-marca get secret marca-api-secrets -o json')"
export DEV_API_SECRET_JSON
export DATABASE_ADAPTER=mysql2
export DATABASE_HOST=127.0.0.1
export DATABASE_PORT="${DEV_MYSQL_PORT:-13306}"
export DATABASE_NAME=marca_inregistrata_production
export DATABASE_USERNAME=marca
export RAILS_ENV=development
# A previously exported DATABASE_URL would override these connection settings.
unset DATABASE_URL

exec ruby -rjson -rbase64 -e '
  secret = JSON.parse(ENV.delete("DEV_API_SECRET_JSON")).fetch("data")
  secret.each do |key, value|
    if key == "DATABASE_PASSWORD" || key.start_with?("ACTIVE_RECORD_ENCRYPTION_")
      ENV[key] = Base64.strict_decode64(value)
    end
  end
  if ARGV == ["--configure"]
    keys = %w[DATABASE_ADAPTER DATABASE_HOST DATABASE_PORT DATABASE_NAME DATABASE_USERNAME DATABASE_PASSWORD]
    keys += secret.keys.grep(/\AACTIVE_RECORD_ENCRYPTION_/)
    content = keys.map { |key| "#{key}=#{ENV.fetch(key).to_json}" }.join("\n") + "\n"
    path = ".env.local"
    if File.exist?(path)
      existing = File.readlines(path).reject { |line| keys.include?(line.split("=", 2).first) }.join
      content = existing + (existing.empty? || existing.end_with?("\n") ? "" : "\n") + content
    end
    File.open(path, File::WRONLY | File::CREAT | File::TRUNC, 0o600) { |file| file.chmod(0o600); file.write(content) }
    puts "Configured api/.env.local for tux1 MySQL at 127.0.0.1:#{ENV.fetch("DATABASE_PORT")}. Keep the SSH tunnel running."
    exit
  end
  exec("bin/rails", *(ARGV.empty? ? ["server", "-p", "3001"] : ARGV))
' -- "$@"
