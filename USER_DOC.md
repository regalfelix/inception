# User documentation

## Services

- **nginx**: serves the website over HTTPS on port 443.
- **wordpress**: the WordPress site and its admin panel.
- **mariadb**: the database.

## Start and stop

From the project root:

- Start: `make upd`
- Stop: `make stop` (your data is kept)

The first start takes a few minutes while WordPress installs.

## Access

Add this line to `/etc/hosts` once:
`127.0.0.1 frey-gal.42.fr`

- Website: https://frey-gal.42.fr
- Admin panel: https://frey-gal.42.fr/wp-admin

The certificate is self-signed, so the browser shows a warning: accept it.

## Credentials

Stored as files in `secrets/` (never committed):

- `secrets/wordpress/wp_admin`, `wp_admin_pass`: administrator login
- `secrets/wordpress/wp_user`, `wp_user_pass`: second user login
- `secrets/mariadb/mysql_root_pass`: database root password

Read one with `cat`, e.g. `cat secrets/wordpress/wp_admin_pass`. Change
WordPress passwords from the admin panel (Users > Profile). Do not edit the
database secrets on an existing install: it would break the connection.

## Check that it works

- `make ps`: `nginx`, `wordpress` and `mariadb` are `Up`.
- The website loads at https://frey-gal.42.fr and you can log in at `/wp-admin`.
- `make logs` shows `Setup finished!!!` for wordpress and no errors.
