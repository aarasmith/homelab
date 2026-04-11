# Traefik Stack

This folder contains a customizable reverse proxy setup. It quickly stands up a traefik instance that uses a docker socket proxy for security, configures crowdsec to monitor for malicious activity - automatically registering a cloudflare bouncer and a traefik bouncer, and an authelia instance for authentication with a postgres/redis backend to allow for scaling, an SMTP setup for emailing password resets, and Duo integration for 2-factor-authentication via push notification.

When adding new services, add them to `services/traefik/routes.yaml` and the `update-proxy-config` workflow will apply changes automatically on push to `main` or `dev`. Routes are rendered dynamically — prod and dev IPs are resolved at build time from the routes file.

All of the static/dynamic/middlewares configurations are in the `services/traefik/rules` folder. `external-routes.yaml` is generated dynamically from `routes.yaml`

Authelia configs will be jinja rendered with the correct secrets/variables before building. Access_control rules can be added to `access_control.yaml` and encrypted with `ansible-vault` (because some of my ACL's are none of your business). They will get decrypted when building using the `ANSIBLE_VAULT_PASSWORD` repository secret.

All the other variables and secrets for traefik and supporting apps can also be stored in an ansible-vault encrypted `vault.yaml` file.

Required vault.yaml vars:
| Variable | Description |
|---|---|
| `DOMAIN` | Your domain |
| `CF_EMAIL` | Cloudflare account email |
| `CF_API_KEY` | Cloudflare API key |
| `AUTHELIA_JWT_SECRET` | JWT secret for Authelia ([generator](https://www.grc.com/passwords.htm)) |
| `AUTHELIA_SESSION_SECRET` | Session secret for Authelia |
| `CF_BOUNCER_TOKEN` | Cloudflare bouncer token (configured automatically during template build) |
| `TZ` | Timezone e.g. `Europe/London` |
| `AUTHELIA_ADMIN_ID` | Authelia SSO admin user ID |
| `AUTHELIA_ADMIN_NAME` | Authelia SSO admin display name |
| `AUTHELIA_ADMIN_EMAIL` | Authelia SSO admin email |
| `AUTHELIA_ADMIN_PASS` | Authelia SSO admin password |
| `AUTHELIA_PG_ENCRYPTION_KEY` | Encryption key for Authelia's Postgres backend |
| `AUTHELIA_PG_PASS` | Postgres password for Authelia |
| `AUTHELIA_PG_USER` | Postgres user for Authelia |
| `AUTHELIA_PG_DB` | Postgres database name for Authelia |
| `SMTP_USERNAME` | SMTP username for Authelia email notifications (password resets) |
| `SMTP_HOST` | SMTP host |
| `SMTP_SENDER_EMAIL` | Sender address for Authelia emails |
| `DUO_HOSTNAME` | Duo API hostname for push notification 2FA |
| `DUO_INTEGRATION_KEY` | Duo integration key |
| `DUO_SECRET_KEY` | Duo secret key |