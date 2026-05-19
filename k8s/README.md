# Kubernetes

Manifests for deploying the Nuxt frontend and Rails API.

## Images

Build and push images using your registry/tag:

```bash
docker build -t ghcr.io/danipopa/marca-inregistrata-web:latest web
docker build -t ghcr.io/danipopa/marca-inregistrata-api:latest api
docker push ghcr.io/danipopa/marca-inregistrata-web:latest
docker push ghcr.io/danipopa/marca-inregistrata-api:latest
```

If you use different image names, update:

- `web-deployment.yaml`
- `api-deployment.yaml`

## Secrets

Copy the example secret and replace the values:

```bash
cp k8s/api-secret.example.yaml k8s/api-secret.yaml
```

Set:

- `RAILS_MASTER_KEY` from `api/config/master.key`
- `SECRET_KEY_BASE` from `cd api && bin/rails secret`
- `DATABASE_PASSWORD` to the same value as `MYSQL_PASSWORD`

Create the MySQL secret too:

```bash
cp k8s/mysql-secret.example.yaml k8s/mysql-secret.yaml
```

Set:

- `MYSQL_ROOT_PASSWORD`
- `MYSQL_PASSWORD`

Keep real secret files out of git.

## Deploy

For the checked-in example secret:

```bash
kubectl apply -k k8s
```

For a real cluster, create your real secret first, then apply the rest:

```bash
kubectl apply -f k8s/namespace.yaml
kubectl -n marca-inregistrata apply -f k8s/mysql-secret.yaml
kubectl -n marca-inregistrata apply -f k8s/api-secret.yaml
kubectl apply -k k8s
```

The default ingress host is `marca-inregistrata.local`. Change it in `ingress.yaml` for production.

## Notes

- MySQL runs as a single-replica StatefulSet named `marca-mysql`.
- MySQL stores data in the StatefulSet `data` PVC.
- The Rails API uses MySQL for primary, cache, queue, and cable production databases.
- The web app talks to the API through the same ingress host with `NUXT_PUBLIC_API_BASE_URL=""`.
