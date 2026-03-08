# Changelog

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