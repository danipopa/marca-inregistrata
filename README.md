# Marca Inregistrata

Website and API for trademark registration requests.

## Apps

- `web/` - Nuxt frontend
- `api/` - Rails API backend
- `k8s/` - Kubernetes manifests for both apps

## Development

Configure the local API once with the development cluster's credentials:

```bash
bash deploy/development/rails.sh --configure
```

This writes ignored `api/.env.local` with permissions `0600`. Development loads
`.env.local` before `.env` and uses MySQL by default; tests still use SQLite.
Keep the SSH tunnel running in a separate terminal:

```bash
bash deploy/development/tunnel.sh
```

Run the Rails API:

```bash
cd api
bin/rails server -p 3001
```

Run the Nuxt frontend:

```bash
cd web
npm run dev
```

The frontend sends trademark request form submissions to:

```text
http://localhost:3001/api/v1/trademark_requests
```

Override this with `NUXT_PUBLIC_API_BASE_URL` when needed.

The local and deployed APIs share the development MySQL database in namespace
`inregistrare-marca` on tux1. Its local endpoint is `127.0.0.1:13306` through SSH
to `10.0.0.250:22122`. Keep the tunnel open whenever running database commands.
Restart any already-running Rails process after configuring the env file.

## Kubernetes

Trademark monitoring workflow, admin controls and provider setup:
[`docs/monitoring.md`](docs/monitoring.md).

See `k8s/README.md` for image names, secrets, ingress, and deployment commands.

For the separate development cluster on `10.0.0.250`, see
[`deploy/development/README.md`](deploy/development/README.md). Open its web/MySQL
tunnel with `bash deploy/development/tunnel.sh`, then start local Rails against
that MySQL with `bash deploy/development/rails.sh`.

Website analytics, technical request metrics, SEO configuration and release checks: [Traffic and SEO](docs/traffic-and-seo.md).

Google Analytics setup: [GA4 integration](docs/google-analytics.md). SEO priorities and rollout: [SEO plan](docs/seo-plan.md).
