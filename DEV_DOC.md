# Developer documentation

## Prerequisites

- Docker Engine + Compose v2
- `make`
- Writable host data path (`DATA_PATH` in Makefile / volume `device` in Compose)
- Secrets under `secrets/`

## Setup from scratch

1. Clone the repository.
2. Create secrets:

   ```bash
   printf '%s' 'your-root-pass' > secrets/db_root_password.txt
   printf '%s' 'your-db-pass'   > secrets/db_password.txt
   cat > secrets/credentials.txt << 'EOF'
   WP_ADMIN_PASSWORD=your-wp-admin-pass
   WP_USER_PASSWORD=your-wp-user-pass
   FTP_PASSWORD=your-ftp-pass
   EOF
   ```

3. Review `srcs/.env` (domain, usernames — no passwords).
4. On the evaluation VM, set data paths to `/home/klaayoun/data` in the Makefile and Compose volume `device` lines.
5. Add hosts entries for `klaayoun.42.fr`, `adminer.klaayoun.42.fr`, `static.klaayoun.42.fr`.
6. `make`

## Makefile / Compose

| Target | Action |
|--------|--------|
| `make` / `make up` | Create data dirs, build, start |
| `make build` | Build images |
| `make down` | Stop and remove containers |
| `make clean` | `down` + remove named volumes |
| `make fclean` | `clean` + prune + delete host data dirs |
| `make re` | Full rebuild |
| `make logs` / `make ps` | Logs / status |

Compose: `srcs/docker-compose.yml`  
Env: `srcs/.env`  
Secrets: `../secrets/` via Compose secrets.

```bash
docker compose -f srcs/docker-compose.yml --env-file srcs/.env build wordpress
docker compose -f srcs/docker-compose.yml --env-file srcs/.env restart nginx
docker compose -f srcs/docker-compose.yml --env-file srcs/.env logs -f mariadb
```

## Data persistence

| Volume | Container path | Host path (current) |
|--------|----------------|---------------------|
| `db_data` | `/var/lib/mysql` | `/home/sora/data/mariadb` |
| `wp_data` | `/var/www/html` | `/home/sora/data/wordpress` |

On evaluation, both host paths must be under `/home/klaayoun/data`. Wipe with `make fclean`.

## Service layout

Each service has its own Dockerfile under `srcs/requirements/<service>/` (bonuses under `bonus/`). Entrypoints `exec` the daemon as PID 1.
