*This project has been created as part of the 42 curriculum by klaayoun.*

# Inception

## Description

Inception is a system-administration project that builds a small web stack with Docker Compose. Mandatory services run in dedicated containers — **NGINX** (TLS reverse proxy / FastCGI), **WordPress + php-fpm**, and **MariaDB** — on a custom bridge network, with persistent named volumes under the host data path.

Bonus services: Redis (WordPress object cache), vsftpd (WordPress files), a static HTML site, Adminer (DB UI), and cAdvisor (container metrics).

## Instructions

### Prerequisites

- Linux VM with Docker and Docker Compose v2
- Secret files under `secrets/` (see below)
- `/etc/hosts` entries:

  ```
  127.0.0.1 klaayoun.42.fr adminer.klaayoun.42.fr static.klaayoun.42.fr
  ```

### Secrets (gitignored)

```
secrets/db_root_password.txt   # single-line MariaDB root password
secrets/db_password.txt        # single-line MariaDB app user password
secrets/credentials.txt        # WP_ADMIN_PASSWORD=...
                               # WP_USER_PASSWORD=...
                               # FTP_PASSWORD=...
```

### Run

```bash
make          # create data dirs, build, start
make down     # stop containers
make clean    # down + remove volumes
make fclean   # clean + prune + wipe data
make re       # fclean then up
make logs
make ps
```

Open `https://klaayoun.42.fr` (accept the self-signed certificate).

On the evaluation VM, set `DATA_PATH` / volume `device` paths to `/home/klaayoun/data`.

## Project description

### Design choices

- **Alpine 3.23** (penultimate stable; never `latest`)
- Custom Dockerfiles only — no ready-made WordPress/MariaDB/NGINX app images
- Docker secrets for passwords; `.env` for non-secret config
- Named volumes with `driver_opts` so data lives under the host data path
- PID 1 is the real daemon (`mysqld`, `php-fpm`, `nginx`, …) — no `tail -f` / `sleep infinity`
- NGINX is the mandatory public entrypoint on host port **443** (TLS 1.2 / 1.3)

### Comparisons

| Topic | Choice |
|-------|--------|
| **VMs vs Docker** | A VM virtualizes hardware/OS; containers share the host kernel and isolate processes. This project runs Docker inside a VM as required. |
| **Secrets vs env vars** | Env vars are convenient but visible in inspect/process lists. Secrets mount as files under `/run/secrets` and stay out of images/git. Non-secrets stay in `.env`. |
| **Docker network vs host network** | A user-defined bridge (`inception`) gives DNS between services. `network: host` / `network_mode: host` is forbidden — it removes network isolation. |
| **Volumes vs bind mounts** | Named volumes are managed by Docker; we set their device path to the host data dir. Raw bind mounts for the two mandatory stores are not allowed. |

### Sources layout

```
Makefile
secrets/                 # local credentials (gitignored)
srcs/.env                # non-secret environment
srcs/docker-compose.yml
srcs/requirements/{nginx,wordpress,mariadb,bonus/...}
```

## Resources

- [Docker Compose documentation](https://docs.docker.com/compose/)
- [NGINX configuring HTTPS servers](https://nginx.org/en/docs/http/configuring_https_servers.html)
- [WP-CLI](https://wp-cli.org/)
- [MariaDB knowledge base](https://mariadb.com/kb/en/)
- [Redis Object Cache (WordPress)](https://wordpress.org/plugins/redis-cache/)
- [cAdvisor](https://github.com/google/cadvisor)
- [Exploring Default Docker Networking Part 1](https://blogs.cisco.com/learning/exploring-default-docker-networking-part-1)

### AI usage

AI assisted with structuring Dockerfiles/entrypoints, Compose wiring, and drafting README / USER_DOC / DEV_DOC. Configs were reviewed against subject constraints (no `latest`, no passwords in Dockerfiles, named volumes, TLS-only 443, no infinite-loop PID 1 hacks) for login `klaayoun`.
