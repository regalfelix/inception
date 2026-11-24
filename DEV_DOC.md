# Developer documentation

## Prerequisites and setup

- Linux VM with Docker Engine, the Compose plugin (`docker compose`), `make`,
  `sudo`, `openssl`, and internet access on first build.
- Add `127.0.0.1 frey-gal.42.fr` to `/etc/hosts`.
- `srcs/.env` holds `LOGIN`, `DOMAIN_NAME` and `MYSQL_DATABASE`. Edit it if your
  login is not `frey-gal`.
- Create the secrets (not in git; `secrets/`):

```
mkdir -p secrets/mariadb secrets/nginx secrets/wordpress
printf 'wpuser'              > secrets/mariadb/mysql_user
openssl rand -hex 16        > secrets/mariadb/mysql_pass
openssl rand -hex 16        > secrets/mariadb/mysql_root_pass
printf 'boss'               > secrets/wordpress/wp_admin      # must not contain "admin"
openssl rand -hex 12        > secrets/wordpress/wp_admin_pass
printf 'boss@example.com'   > secrets/wordpress/wp_admin_email
printf 'editor'             > secrets/wordpress/wp_user
openssl rand -hex 12        > secrets/wordpress/wp_user_pass
printf 'editor@example.com' > secrets/wordpress/wp_user_email
openssl req -x509 -nodes -newkey rsa:2048 -days 365 \
  -keyout secrets/nginx/private-key.pem -out secrets/nginx/certificate.pem \
  -subj "/CN=frey-gal.42.fr" -addext "subjectAltName=DNS:frey-gal.42.fr"
```

## Build and launch

| Command | Effect |
|---|---|
| `make` | Build and start in the foreground |
| `make upd` | Build and start in the background |
| `make stop` | Remove containers, keep data |
| `make ps` / `make logs` | Status / logs |
| `make clean` | Remove **all** Docker containers and images on the machine |
| `make fclean` | `clean`, then delete `/home/<login>/data` and prune Docker |
| `make re` / `make fre` | `clean` / `fclean`, then rebuild |

The Makefile wraps
`docker compose -f ./srcs/docker-compose.yml --env-file ./srcs/.env` and creates
the host data folders first.

## Managing containers and volumes

```
docker compose -f srcs/docker-compose.yml --env-file srcs/.env restart nginx
docker exec -it mariadb mariadb -uroot -p
docker logs wordpress
docker volume ls
docker volume inspect srcs_wordpress_data
docker network ls
```

## Data and persistence

- WordPress files: volume `wordpress_data`, host `/home/<login>/data/wordpress`.
- Database: volume `mariadb_data`, host `/home/<login>/data/mariadb`.

Both are named volumes using the `local` driver with `type: none, o: bind`.
They survive `make stop` and reboots. First-time setup runs only if its marker
is missing (`/var/www/html/init` for WordPress, the `wordpress` database folder
for MariaDB), so reset both folders together with `make fclean`.
