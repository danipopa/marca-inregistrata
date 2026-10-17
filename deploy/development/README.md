# Development cluster

This overlay deploys the production Rails/Nuxt/MySQL architecture in namespace
`inregistrare-marca` on the Kubernetes VMs hosted by `10.0.0.250`.
Rails in the cluster runs with `RAILS_ENV=production`.

Differences from production:

- Dedicated NFS directories on `192.168.100.1` under
  `/home/storage/ns/inregistrare-marca/{mysql,storage}`.
- Application images built from this checkout, stored in the existing cluster
  registry at `192.168.100.16:30501` with tag `development`.
- A namespace-local Nginx gateway exposed by MetalLB at `192.168.100.240:80`,
  also available on NodePort `30081`. Production domain names and TLS are not applied.
- Separate generated MySQL credentials and application signing secret. Payment
  and SMTP credentials are not copied into the development API Secret.

Prepare the NFS directories on `tux1`, with `storage` owned by UID/GID `1000:1000`.
Create `marca-mysql-secrets` and `marca-api-secrets` as described in
`../../k8s/README.md`, using separate development database passwords.
Then build/push the images and apply with the development cluster context:

```bash
# Keep this registry tunnel running in another terminal:
ssh -p 22122 -N -o ExitOnForwardFailure=yes \
  -L 15001:192.168.100.16:30501 root@10.0.0.250
```

On the workstation with Docker access:

```bash
docker build -t localhost:15001/inregistrare-marca-api:development api
docker build -t localhost:15001/inregistrare-marca-web:development web
docker push localhost:15001/inregistrare-marca-api:development
docker push localhost:15001/inregistrare-marca-web:development
```

On `tux1`, from a copy of this repository:

```bash
kubectl apply -k deploy/development
```

Apply the dedicated MetalLB pool and Layer 2 advertisement separately (their
namespace is `metallb-system`):

```bash
kubectl apply -f deploy/development/metallb.yaml
```

From `tux1`, open <http://192.168.100.240>. This address is on the VM subnet;
workstations need a route through `10.0.0.250` or the SSH tunnel below.

Reusing the `development` image tag requires a rollout restart after pushing:

```bash
kubectl -n inregistrare-marca rollout restart deployment/marca-api deployment/marca-web
```

## Use from your workstation

Run the tunnel in one terminal:

```bash
bash deploy/development/tunnel.sh
```

Open <http://localhost:18080> to use the deployed website and API. The gateway is
also reachable from the VM network at `http://192.168.100.15:30081`.

To configure ordinary Rails commands to use this MySQL, run once:

```bash
bash deploy/development/rails.sh --configure
cd api
bin/rails server -p 3001
```

Development automatically reads ignored `api/.env.local` before `api/.env`.
Restart an existing Rails process after configuring. Keep the tunnel running.
You can also launch Rails while fetching fresh credentials each time:

```bash
bash deploy/development/rails.sh
```

This reads the development API Secret over SSH and starts Rails on port `3001`.
Run the frontend with `cd web && npm run dev`, using
`NUXT_PUBLIC_API_BASE_URL=http://localhost:3001`.
The local API and deployed API share the development database.

For Rails commands, pass arguments, for example:

```bash
bash deploy/development/rails.sh db:migrate
```

Override `DEV_SSH_HOST`, `DEV_SSH_PORT`, `DEV_MYSQL_PORT`, or `DEV_WEB_PORT` as
needed. Only one tunnel should bind the remote MySQL port at a time.
The SQL dump contains database rows, not uploaded files; copy uploaded files
separately if needed. Restored encrypted MFA data requires matching original
Active Record encryption keys.
