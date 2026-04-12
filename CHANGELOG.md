# Changelog

## [1.3.0] - 2026-04-12

### Added
- New `ombi` service: standalone unprivileged LXC running Ombi in Docker, pinned to `lscr.io/linuxserver/ombi:development` for timely security updates
- New `jellyfin` service workflows: `backup`, `restore`, `update-system`
- New `ombi` service workflows: `lxc`, `backup`, `restore`, `update-system`
- `ansible/common/apt-upgrade.yaml` — shared playbook for apt dist-upgrade without Docker steps; for use with bare-metal services
- `ansible/common/add-ro-media-mount.yaml` — shared playbook to bind-mount `/mnt/media` into an LXC read-only

### Changed
- `jellyfin-ombi` service split into separate `jellyfin` and `ombi` services
- Jellyfin LXC now deploys from `debian-12-standard` base template directly, removing dependency on the custom `jellyfin-ombi-debian12` template
- Jellyfin media mount is now read-only
- Ombi Traefik route updated to port `3579` and new LXC IP (`10.1.1.24` prod / `10.1.1.124` dev)
- `jellyfin-setup.yaml` stripped of Ombi installation tasks

### Removed
- `jellyfin-ombi` combined LXC template workflow and `jellyfin-ombi-debian12` template
- `jellyfin-ombi` migration workflows (`jellyfin-migration.yaml`, `ombi-migration.yaml`)
- Bare-metal Ombi installation (apt repo was significantly out of date)

## [1.2.3] - 2026-04-11

## Changed
- Changed the music containers' docker bind mounts to use the standard trash-guides path used by all the other indexers/downloaders (arr, torrents)

## [1.2.2] - 2026-04-10

### Added
- add `replication=0` to external mount point setups in `add-backup-mounts`, `add-cattle-share`, and `add-unprivileged-nfs-mount` to allow setting replication jobs across nodes

## [1.2.1] - 2026-04-10

### Fixed
- The tcp router for git ssh in traefik's external-routes was not populating due to the yaml structure changes made to `traefik/routes.yaml` to support multi-node load balancing
- Added a 15 second sleep step to give template LXC's time to spin up before trying to obtain the IP address

## [1.2.0] - 2026-04-10

### Added
- **Kafka** — 3-broker KRaft cluster distributed across all 3 Proxmox nodes with kafka-ui on each broker behind a load-balanced Traefik route
- **Torrents** — qBittorrent behind Gluetun VPN tunnel, pre-configured with TRaSH Guides-compatible paths and download categories
- **Music** — Lidarr + slskd (Soulseek) + Navidrome stack for music acquisition and streaming
- `lookup-env` composite action — single source of truth for prod/dev environment resolution, supports `release/**` as prod-equivalent
- `scope-pve-env` and `scope-aws-env` actions — output-based replacements for the old normalize actions
- `get-pve-node-ip` action — resolves a node name to its IP as a step output
- `setup-env` reusable workflow — exposes `deploy_env` as a workflow-level output
- `lxc-3-node-ansible` reusable workflow — derives LXC names and IPs dynamically from a single `service_name` input
- `lxc-start` reusable workflow (renamed from `lxc-post-deploy`)
- `update-docker-lxc.yaml` common playbook — apt dist-upgrade + docker image pull + container recreate + image prune
- `add-backups-mount.yaml` common playbook — NAS bind mount scoped per-service and per-environment
- `backup-appdata.yaml` / `restore-appdata.yaml` common playbooks — restic-based backup with 5-snapshot retention and clean-slate restore
- `add-tun-device.yaml` common playbook — configures TUN device passthrough for LXCs that need VPN
- Backup, restore, update-system, and update-config workflows added for arr, airflow, music, torrents and traefik
- `force` dispatch input on all `lxc.yaml` workflows to trigger full deploy from any branch
- `apply` input on `lxc-terraform` and `dump_template` input on `lxc-template` — explicit control replacing branch inference
- `created` output from `lxc-terraform` — downstream setup jobs only run when LXC was actually just created
- `release/**` branch support across all deploy workflows
- Multi-server support in `routes.yaml` and `external-routes.yaml` — enables load-balanced Traefik routes
- New Traefik routes: `kafka`, `qbit`, `lidarr`, `soulseek`, `navidrome`

### Changed
- All composite actions migrated from `GITHUB_ENV` to `GITHUB_OUTPUT` — eliminates global state mutation
- `lxc-multi-ansible` renamed to `lxc-3-node-ansible`, simplified to single `service_name` input with dynamic IP resolution
- Service-specific LXC templates (arr, airflow, kafka) removed — services deploy from `docker-debian12` base with idempotent setup playbooks
- Template playbooks renamed/refactored to `*-setup.yaml`
- Airflow postgres converted from named Docker volume to bind mount at `/docker/appdata/airflow-postgres`
- Airflow DAGs/logs paths standardised to `/docker/appdata/airflow/dags` and `/docker/logs/airflow`
- `traefik/update-proxy-config` branch guard removed
- All service `lxc.yaml` workflows now resolve prod/dev IP via `setup-env` output instead of `github.ref_name == 'main'` — fixes incorrect dev IP assignment on `release/**` branches
- Updated README

### Removed
- `normalize-pve-env` action — replaced by `scope-pve-env`
- `normalize-aws-env` action — replaced by `scope-aws-env`
- `lxc-post-deploy` workflow — replaced by `lxc-start`
- All service-specific migration playbooks (arr, airflow) — superseded by restic restore flow
- `kafka-template.yaml` — image pre-pulling removed

### Repo variables renamed
- `PVE_DEFAULT_TARGET_NODE` -> `PVE_DEFAULT_NODE`
- `PVE_DEFAULT_TARGET_NODE_DEV` -> `PVE_DEFAULT_NODE_DEV`
- `PVE_NODE_IP` -> `PVE_DEFAULT_NODE_IP`
- `PVE_NODE_IP_DEV` -> `PVE_DEFAULT_NODE_IP_DEV`

### New secrets required
- `RESTIC_PASSWORD`

## [1.1.0] - 2026-03-12

### Added

- **Multi-node cluster support** — LXC deployments can now target any node in the production cluster (`mother`, `fish`, `fastfood`) via the `target_node` input on `lxc-terraform.yaml`. The correct node is automatically selected for SSH and Ansible inventory in all downstream workflows.
- **`lookup-lxc-vmid-node` action** — New composite action that resolves both the VMID and the node an LXC is running on via `pvesh`. Replaces the old `lookup-lxc-vmid-ip` action across all common workflows.
- **`lookup-lxc-ip` action** — New composite action that resolves an LXC IP given a VMID and node IP. Decoupled from VMID lookup to allow node-aware IP resolution after `normalize-pve-env` has run.
- **`setup-ssh` action** — New composite action that writes the SSH private key and scans all production PVE node IPs into `known_hosts` (or just the dev node on non-`main` branches). Eliminates repeated inline SSH setup across all common workflows.
- **Airflow service** — Full CI/CD for an Apache Airflow stack deployed on the `fastfood` node:
  - `lxc-template` workflow builds an `airflow-debian12` template from `docker-debian12`.
  - `lxc-terraform` workflow provisions VMID 303 at `10.1.1.30/24` (prod) / `10.1.1.130/24` (dev) with 4 GB RAM and 2 cores.
  - `airflow-start.yaml` playbook writes vault secrets to `.env`, initialises the database, creates the admin user, and starts the full stack.
  - `deploy-dags` workflow syncs DAGs from `services/airflow/dags/` to the running LXC on push.
  - `airflow-migration.yaml` playbook handles backup (postgres dump + DAGs archive) and restore across LXCs.
  - Airflow added to the Traefik proxy at `airflow.<DOMAIN>`.
- **Dynamic Traefik proxy routes** — `services/traefik/routes.yaml` is now the single source of truth for all reverse-proxy service definitions. `external-routes.yaml` is generated from it via `frender` at build time, with prod and dev IPs resolved per environment. Adding a new proxied service no longer requires editing `external-routes.yaml` directly.
- **`update-proxy-config` trigger expansion** — The workflow now also fires on changes to `services/traefik/routes.yaml` and `services/traefik/docker-compose.yaml`.
- **Dummy tfvars in `lxc-destroy`** — Added a `vars.auto.tfvars` stub to satisfy Terraform variable validation during destroy without requiring real deployment values.
- **`lxc-post-deploy` now accepts `lxc_name` instead of `vmid`** — Post-deploy workflow resolves the VMID dynamically via the new lookup actions, removing the need for callers to hardcode VMIDs.

### Changed

- **`normalize-pve-env` action** — Now accepts an optional `target_node` input (`mother`, `fish`, `fastfood`) and sets `PVE_NODE_IP` and `PVE_PASSWORD` from the corresponding per-node repo variables when a specific node is requested. `PVE_NODE_IP` is still used as the default (e.g. for templates and cluster-wide lookups where a specific node doesn't matter).
- **`lxc-ansible`, `lxc-migration`, `lxc-post-deploy`** — Reordered steps so SSH setup and VMID/node lookup happen before `normalize-pve-env`, enabling the correct per-node variables to be set based on where the LXC is actually running.
- **Traefik `frender` calls refactored** — Authelia config rendering and Traefik rules rendering are now separate named steps in both `traefik-template.yaml` and `traefik-update.yaml`. Rules rendering now passes `routes.yaml` and an `env` variable so templates can resolve environment-specific IPs.
- **Airflow deployed on `fastfood` node** — Moved to `fastfood` to take advantage of its higher single-core performance for scheduling workloads.
- **`lxc-post-deploy` callers updated** — `arr`, `jellyfin-ombi`, and `traefik` service workflows updated to pass `lxc_name` instead of a hardcoded `vmid`.
- Minor step name capitalisation consistency (`debug` -> `Debug`, `inject` -> `Inject`) across common workflows.

### Removed

- **`lookup-lxc-vmid-ip` action** — Replaced by the combination of `lookup-lxc-vmid-node` and `lookup-lxc-ip`.
- **`id: tfout` on Terraform Apply step** — Unused output reference removed from `lxc-terraform.yaml`.

### Migration notes

Add the following new repo variables (existing `PVE_NODE_IP` can stay — it is still used as a default):

| New variable | Purpose |
|---|---|
| `PVE_NODE_IP_MOTHER` | SSH/API target for the `mother` node |
| `PVE_NODE_IP_FISH` | SSH/API target for the `fish` node |
| `PVE_NODE_IP_FASTFOOD` | SSH/API target for the `fastfood` node |

All `lxc-post-deploy` callers must also be updated to pass `lxc_name` instead of `vmid`.

---

## [1.0.0] - 2026-03-08

### Repository Structure
- Reorganised repository from a flat `ansible/` directory into a purpose-driven layout with `services/`, `base-templates/`, and `ansible/common/` top-level directories
- Each service now lives under `services/<name>/` with subdirectories for `ansible/`, `docker/`, and any service-specific config (e.g. `authelia/`, `rules/`, `crowdsec/`)
- Reusable LXC base images (docker, postgres17) moved to `base-templates/` to distinguish them from deployable services
- Added `docs/images/` for repository documentation assets

### Workflows
- Renamed all workflows to follow a consistent `scope | service | action` naming convention (e.g. `services | traefik | template`) for readable sorting in the Gitea UI
- Reorganised workflow files into `services/` and `base-templates/` subdirectories under `.gitea/workflows/` mirroring the repository structure
- All workflow `paths:` triggers updated to reflect new file locations
- Added `playbook` input to `lxc-template.yaml` common workflow, replacing hardcoded path construction — callers now pass the full playbook path explicitly
- Added `lxc-post-deploy.yaml` common workflow replacing inline post-deploy job steps across all service workflows — ensures LXC is started via `pct start` before waiting for it to come online
- Added `lxc-destroy.yaml` common workflow for manually triggered LXC destruction with branch-name confirmation to prevent accidental runs
- Added `Terraform Refresh` step to `lxc-terraform.yaml` to reconcile state before planning
- Added `update-proxy-config.yaml` workflow for Traefik, triggered automatically on changes to rules, authelia config, or acquis config
- Fixed `lxc-migrate.yaml` playbook path to correctly reference migration playbooks rather than template playbooks
- Added `dev` branch trigger to arr, jellyfin-ombi, and jellyfin-ombi template workflows
- Fixed `inject ansible pve task` step in `lxc-template.yaml` to use `$GITHUB_WORKSPACE` for an absolute path to `dump-lxc-to-template.yaml`, resolving breakage caused by variable playbook depth

### Traefik
- Moved all Traefik config from `ansible/traefik/` to `services/traefik/` with `ansible/`, `authelia/`, `rules/`, and `crowdsec/` subdirectories
- Updated all Ansible playbooks to use `service_dir: "{{ playbook_dir }}/.."` for referencing files outside the `ansible/` subdirectory
- Added `effective_domain` variable to derive `dev.<DOMAIN>` automatically on non-main branches
- Added `sed` step to patch decrypted `vault.yaml` with `dev.` prefixed domain before frender rendering on non-main branches, ensuring all rendered configs and the Docker `.env` use the correct domain
- Moved `vault.yaml` into `services/traefik/ansible/` to align with `playbook_dir` resolution
- Added CrowdSec `acquis.yaml` at `services/traefik/crowdsec/acquis.yaml` configured to monitor Traefik access logs, Authelia logs, and host syslog/auth.log
- Added copy and restart steps for `acquis.yaml` in both `traefik-template.yaml` and `traefik-update.yaml`
- Added `traefik-update.yaml` restart step for CrowdSec when acquis config changes
- Updated Authelia session `expiration` to 24 hours and `inactivity` to 4 hours
- Updated Authelia `max_retries` to 10
- Fixed `update-proxy-config.yaml` path trigger from `configuration.yaml` to `configuration.yml`

### README
- Full rewrite to reflect new repository structure, workflow conventions, and usage patterns
- Added physical infrastructure inventory section
- Added repository structure diagram with per-service layout explanation
- Updated all secrets and variables documentation — added `ANSIBLE_VAULT_PASSWORD`, corrected variable names (`PVE_TEMPLATES_DIR`, `PVE_DEFAULT_TARGET_NODE`), documented `_DEV` suffix convention
- Added sections for destroying LXCs, running arbitrary playbooks, and migrating services
- Moved development workflow section to top level and expanded branch behaviour description