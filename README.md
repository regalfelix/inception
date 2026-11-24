*This project has been created as part of the 42 curriculum by frey-gal.*

# Inception

## Description

A small web infrastructure run with Docker Compose inside a virtual machine.
Three containers, each built from our own Dockerfile on `debian:12.15`, serve a
WordPress site over HTTPS:

- **nginx**: the only entry point, port 443, TLS 1.3 only.
- **wordpress**: WordPress with php-fpm, no web server.
- **mariadb**: the database.

They share a Docker network (`inception`). Two named volumes store the
database and the site files under `/home/frey-gal/data` on the host.

### Project description

**Docker and sources.** Each service has its own Dockerfile and entrypoint
script in `srcs/requirements/<service>/`. `srcs/docker-compose.yml` defines the
images, network, volumes and secrets, and the `Makefile` drives it. Non-sensitive
settings (login, domain, database name) are in `srcs/.env`; passwords and the
TLS key are Docker secrets in `secrets/` (kept out of git).

**Design choices.** One process per container, started with `exec` so it is
PID 1. Containers restart on failure. WordPress is installed automatically on
first start with WP-CLI.

**Virtual Machines vs Docker.** A VM emulates a whole machine with its own
kernel: heavy and slow to start. A container is an isolated process sharing the
host kernel: light and fast, but less strongly isolated.

**Secrets vs Environment Variables.** Environment variables are visible in
`docker inspect` and to child processes, so they hold only non-sensitive
settings. Secrets are mounted as files in `/run/secrets/`, only in the services
that need them, and hold passwords and keys.

**Docker Network vs Host Network.** A Docker network isolates containers and
lets them reach each other by service name, with only published ports exposed.
Host network removes that isolation and is forbidden by the subject.

**Docker Volumes vs Bind Mounts.** Named volumes are managed by Docker and
independent of the host layout; bind mounts map a specific host path. Here the
named volumes use the `local` driver with `type: none, o: bind` so their data
sits in `/home/frey-gal/data`, as the subject requires.

## Instructions

Requirements: a Linux VM with Docker (Compose plugin), `make` and `sudo`.

1. Create the files in `secrets/` (see [DEV_DOC.md](DEV_DOC.md)).
2. Add the domain to the hosts file:
   `echo "127.0.0.1 frey-gal.42.fr" | sudo tee -a /etc/hosts`
3. Run `make upd`.
4. Open `https://frey-gal.42.fr` (accept the self-signed certificate warning).

Stop with `make stop`. See [USER_DOC.md](USER_DOC.md) and
[DEV_DOC.md](DEV_DOC.md) for details.

## Resources

- [Docker documentation](https://docs.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/)
- [NGINX documentation](https://nginx.org/en/docs/)
- [WP-CLI](https://wp-cli.org/)
- [MariaDB Knowledge Base](https://mariadb.com/kb/en/documentation/)
