# Marca Inregistrata

Website and API for trademark registration requests.

## Apps

- `web/` - Nuxt frontend
- `api/` - Rails API backend
- `k8s/` - Kubernetes manifests for both apps

## Development

Run the Rails API:

```bash
cd api
bin/rails db:migrate
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

## Kubernetes

See `k8s/README.md` for image names, secrets, ingress, and deployment commands.
