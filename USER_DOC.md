# User documentation

## Services

| Service     | Role                           | How to reach it                                             |
| ----------- | ------------------------------ | ----------------------------------------------------------- |
| NGINX       | HTTPS entrypoint (TLS 1.2/1.3) | `https://klaayoun.42.fr`                                    |
| WordPress   | Site + admin (php-fpm)         | `https://klaayoun.42.fr/wp-admin`                           |
| MariaDB     | Database                       | Internal only (`mariadb:3306`)                              |
| Redis       | Object cache                   | Internal only                                               |
| Adminer     | DB web UI                      | `https://adminer.klaayoun.42.fr` or `http://localhost:8081` |
| Static site | Showcase page                  | `https://static.klaayoun.42.fr` or `http://localhost:8080`  |
| FTP         | Edit WordPress files           | `ftp://localhost` (`FTP_USER` from `.env`)                  |
| cAdvisor    | Container metrics              | `http://localhost:8082`                                     |

## Start and stop

```bash
make up      # or: make
make down
make stop
make start
```

## Access the website and admin panel

1. Add to `/etc/hosts`:

   ```
   127.0.0.1 klaayoun.42.fr adminer.klaayoun.42.fr static.klaayoun.42.fr
   ```

2. Open `https://klaayoun.42.fr` (accept self-signed cert).
3. WordPress admin: `https://klaayoun.42.fr/wp-admin`
   - Admin user: `klaayoun` (must not contain “admin”)
   - Password: `WP_ADMIN_PASSWORD` in `secrets/credentials.txt`
4. Second user: `editor` / `WP_USER_PASSWORD`

## Credentials

| Secret                   | File                           |
| ------------------------ | ------------------------------ |
| MariaDB root             | `secrets/db_root_password.txt` |
| MariaDB app user         | `secrets/db_password.txt`      |
| WP admin / WP user / FTP | `secrets/credentials.txt`      |

Non-secret names live in `srcs/.env`. Never commit real passwords.

## Health checks

```bash
make ps
make logs
curl -kI https://klaayoun.42.fr
```

Data directories: `$DATA_PATH/mariadb` and `$DATA_PATH/wordpress` (see Makefile / `.env`).
