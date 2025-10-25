# Odoo 18 + React (Vite) on Docker Compose

This repo wires a modern React SPA (built with Vite) together with Odoo 18, all fronted by a single Nginx. The React app lives in its own container (built from `react/Dockerfile`) and is reverse‑proxied at `/react`, while Odoo is proxied at `/`.

If you’re a developer picking this up, this guide explains the architecture, how to run it end‑to‑end, how to rebuild the frontend only, how to manage the optional redirect module, and how to troubleshoot common issues.

---

## Quickstart: run, restart, logs

Everything below assumes you run commands from the repo root.

Start (or rebuild) everything

```bash
docker compose up -d --build
```

Stop everything (containers only)

```bash
docker compose down
```

Stop and remove containers + named volumes (DANGEROUS: wipes DB & filestore)

```bash
docker compose down -v
```

See what’s running

```bash
docker compose ps
```

Restart all services

```bash
docker compose restart
```

Restart just one service

```bash
docker compose restart react
docker compose restart odoo
docker compose restart nginx
```

Rebuild only the React app (don’t touch Odoo/DB)

```bash
docker compose up -d --no-deps --build react
```

Tail logs (follow) per service

```bash
docker compose logs -f odoo
docker compose logs -f react
docker compose logs -f nginx
```

All logs with a time window

```bash
docker compose logs -f --since=10m
```

Quick health checks (locally)

```bash
curl -I http://localhost/
curl -I http://localhost/react/
```

Open a shell inside a container

```bash
docker compose exec odoo bash
docker compose exec react sh
docker compose exec nginx sh
docker compose exec db psql -U odoo -d postgres
```

— That’s the 90% you’ll use day-to-day. Keep reading for deeper details.

---

## Architecture

- Services (Docker Compose):
  - `db` — PostgreSQL 15
  - `odoo` — Odoo 18 with extra addons mounted from the host
  - `react` — Multi‑stage Node build + Nginx runtime serving the SPA
  - `nginx` — Front proxy for both Odoo and React
  - `pgadmin` — Optional DB admin UI (port 5050)

- Routing (front Nginx):
  - `/` → Odoo (`odoo:8069`)
  - `/websocket` → Odoo bus/longpolling (`odoo:8072`)
  - `/react` → React container (`react:80`)

- Volumes and mounts (key ones):
  - `./addons/custom → /mnt/extra-addons/custom`
  - `./addons/enterprise → /mnt/extra-addons/enterprise`
  - `./addons/community → /mnt/extra-addons/community`
  - `./odoo.conf → /etc/odoo/odoo.conf`

- Addons preparation script:
  - `prepare_addons.sh` runs at Odoo startup to:
    - Build a flat “auto” symlink farm under `/mnt/extra-addons/auto` from all mounted addons folders
    - Optionally install Python requirements declared by modules

- React build:
  - Built by its own image via `react/Dockerfile`
  - Served by the React container’s Nginx
  - Front Nginx proxies `/react` to this container
  - Vite `base` is set to `/react/` so built asset URLs resolve correctly behind the proxy

---

## First run (local or EC2)

1) Prereqs
- Docker and the newer Docker Compose plugin (use `docker compose`, not `docker-compose`).
- On EC2, allow inbound port 80 (and 5050 if you want pgAdmin).

2) Start the stack
- From the repo root, run:

```bash
docker compose up -d --build
```

- Wait ~30–60s; Odoo first-time init can take a bit while addons get prepared.

3) Access the apps
- Odoo: `http://<host>/`
- React: `http://<host>/react/`
- pgAdmin (optional): `http://<host>:5050/`

Notes for EC2
- Replace `<host>` with your public IP or domain (e.g., `http://3.95.x.y/`).
- Open needed ports in the EC2 security group.

---

## Day‑to‑day developer tasks

### Rebuild only the React app
- Fast path to rebuild the SPA after code changes without touching Odoo:

```bash
docker compose up -d --no-deps --build react
```

- Clean rebuild (ignore cache) if needed:

```bash
docker compose build --no-cache react
docker compose up -d react
```

### Restart services quickly
- Restart just React

```bash
docker compose restart react
```

- Restart Odoo

```bash
docker compose restart odoo
```

- Restart Nginx

```bash
docker compose restart nginx
```

### Check logs
- Tail logs for selected services

```bash
docker compose logs -f odoo
docker compose logs -f react
docker compose logs -f nginx
```

- All services with timestamps

```bash
docker compose logs -f --since=10m
```

### Verify endpoints
- Odoo root

```bash
curl -I http://localhost/
```

- React app

```bash
curl -I http://localhost/react/
```

---

## Project layout

```
.
├─ docker-compose.yml         # Orchestrates services
├─ nginx.conf                 # Front proxy config for Odoo (/), React (/react), bus (/websocket)
├─ odoo.conf                  # Odoo config (db connection, workers, addons_path)
├─ prepare_addons.sh          # Builds /auto symlink farm & installs python deps
├─ addons/
│  ├─ custom/
│  ├─ enterprise/
│  └─ community/
└─ react/
   ├─ Dockerfile             # Multi-stage Node build → Nginx runner
   ├─ vite.config.ts         # base: '/react/'
   └─ src/ ...
```

---

## Troubleshooting guide

### 1) 502 Bad Gateway at `/`
- Likely Odoo isn’t up or failed to start. Check container status and logs.
- Common cause: startup script not executable. We call it via `bash` in Compose (“`bash /usr/local/bin/prepare_addons.sh`”) to avoid the executable bit problem.

```bash
docker compose ps
docker compose logs --tail=200 odoo
```

### 2) Redirect loop between React and Odoo
- Use the safe route: `http://<host>/react_redirect/disable` (must be logged in) to clear your user’s Home Action.
- React “Back to Odoo” button is resilient: it tries the disable route (if present) then navigates to `/web` anyway.
- You can also clear Home Action in Odoo UI: Preferences → Home Action.

### 3) Invalid manifest version
- Odoo 18 accepts: `x.y`, `x.y.z`, `18.0.x.y`, or `18.0.x.y.z`. Example: `18.0.1.0`.
- Fix in `__manifest__.py`, restart Odoo.

### 4) FileNotFoundError for `odoo_react_redirect/data/actions.xml`
- Make sure the module folder name is exactly `odoo_react_redirect` (underscores, not hyphens).
- Verify the file exists inside the Odoo container:
  - `/mnt/extra-addons/custom/odoo_react_redirect/data/actions.xml`
- If missing, check you’re running Compose from the repo root (so mounts resolve correctly) and that your code is present on the EC2 host.
- (Re)run the addon prep script to refresh the `/auto` symlink farm.

```bash
docker compose exec odoo bash -lc 'ls -lah /mnt/extra-addons/custom/odoo_react_redirect/data/ && ls -lah /mnt/extra-addons/auto | head'
```

### 5) React assets 404 under `/react/`
- Ensure `vite.config.ts` has `base: '/react/'` so built assets are referenced correctly behind the proxy.
- Rebuild the React image and restart only the `react` service.

---

## Advanced: change routes

- Serve React at root and Odoo under `/odoo`:
  - Update `nginx.conf` locations to proxy `/` → `react`, and `/odoo` → `odoo`.
  - Update Vite `base` to `'/'` and rebuild React.

- Serve React statically from main Nginx (no separate React container):
  - Mount the built `react/dist` into main Nginx and use `alias` + `try_files`. This is a separate setup (we currently use the standalone React container).

---

## Data persistence

- Database: `odoo-db-data` Docker volume
- Odoo filestore: `odoo-web-data` Docker volume
- Python packages cache: `odoo-python-packages` (if present in Compose)

Backups: dump Postgres + copy filestore before major changes.

---

## Security & production notes

- Put the stack behind a real TLS proxy (e.g., an ALB or Nginx with certs). This sample serves HTTP only.
- Lock down pgAdmin to trusted IPs or remove if not needed.
- Use strong admin passwords and rotate them.
- For EC2, restrict inbound to ports you actually need (80/443, 5050 optional).

---

## FAQ

- Q: What’s my Odoo DB name?
  - A: In this sample it’s typically `admin`. If unsure, list DBs in Postgres.

- Q: How do I completely reset only the React container?
  - A: Rebuild with `--no-deps` so other services remain untouched.

- Q: My editor shows TypeScript JSX errors but the site works.
  - A: The container builds dependencies inside Docker; your local editor may not have node_modules. Run `npm install` locally if you want local type checks.

---

Happy shipping!
