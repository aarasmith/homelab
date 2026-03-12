# Homelab
This repository is for provisioning local/cloud infrastructure with terraform on Proxmox/AWS and building/deploying/managing it with ansible. Everything is orchestrated by and runs on CI/CD using the `gitea-runner-tools` container from the `runners` repo.

## Physical infrastructure
The current configuration is:
- A production 3-node Proxmox cluster with 2 Lenovo m720q's and an HP elitedesk 800 g4 all with 8th gen i5's.
  - The lenovo's have each have a dual 10Gbe NIC installed to handle inter-cluster traffic. This is point-to-point routed to remove the need for a 10Gbe switch.
  - The lenovos are designed to absorb each other's load if a node goes down. ZFS replication is done every 15 minutes to allow quick failover with minimal data loss
  - The HP has a desktop i5 rather than the low-power "T" versions in the lenovos - so it is used for workloads that require higher single core performance like databases.
  - All 3 nodes have 64GB RAM, 6 Cores, 256GB 2.5" SSD boot drives, and 1TB NVMe's for VM/LXC storage. This allows seamless switching between nodes.
- A Truenas core box running on an HP Microserver Gen8 serving as network storage with 4 10TB SAS drives running RAIDZ1 for 30TB usable
  - The SAS drives connect to an HBA installed in the PCIe slot with 1 external port for future expansion to a DAS or a tape drive.
  - 2 480GB SSD's are connected to the onboard SATA controller as mirrored vdevs for the metadata are crammed where the optical drive used to be
  - It has 16GB ECC RAM and an 256GB SSD boot drive
- A single lenovo m720q node as a DEV PVE node for testing
  - i5 6 cores, 16GB RAM, 256GB SSD, and 256GB NVMe
- A Proxmox Backup Server running on another lenovo m720q with an i3, 128GB NVMe boot drive, and 1TB SSD with power loss protection

![physical infrastructure](docs/images/homelab.jpg)

## Prerequisites
### CI/CD runner image
You must specify in the repo vars as `RUNNER_IMAGE` a container image you have access to that has terraform, ansible, and nodejs installed. This also uses a CLI jinja2 template rendering tool, `frender`, that is preinstalled. Example:
```
git.arasmith.org/admin/gitea-runner-tools:latest
```
### Secrets
The following repo secrets are required:

```
AWS_ACCESS_KEY_ID=<access key id to aws for provider>
AWS_SECRET_ACCESS_KEY=<access key to aws>
PVE_USER=<proxmox username e.g. some-username@pam>
PVE_PASSWORD=<default proxmox password> #required for the TF provider
PVE_PASSWORD_<NODE-NAME>=<node proxmox password>
PVE_PASSWORD_DEV=<dev proxmox password>
LXC_PASSWORD=<password for LXC's>
MASTER_SSH_PUBLIC_KEY=<public key to place on built infra>
MASTER_SSH_PRIVATE_KEY=<private key to access built infra>
ANSIBLE_VAULT_PASSWORD=<password for ansible-vault encrypted files>
```

Ensure that the public key is also added to the PVE host as ansible needs to run a few commands on the host to dump template builder LXCs to a vzdump and rename the file.

Dev/feature branches use the same secrets suffixed with `_DEV` where applicable (e.g. `PVE_USER_DEV`, `PVE_PASSWORD_DEV`).

### Variables
The following repo variables are required:

```
AWS_REGION=<aws region for backend bucket/any aws infra>
AWS_TF_BACKEND_BUCKET=<pre-existing S3 bucket name for your terraform state files>
GATEWAY=<the network gateway ip>
RUNNER_IMAGE=<address of image for actions runner e.g. git.arasmith.org/admin/gitea-runner-tools:latest>
PVE_NODE_IP=<ip address of the default proxmox node (used for templates and lookups)>
PVE_NODE_IP_<NODE-NAME>=<ip address of each proxmox node>
PVE_NODE_IP_DEV=<ip address of the dev proxmox node>
PVE_DISK_STORAGE=<the storage for the lxc disks>
PVE_DEFAULT_TARGET_NODE=<default node name for builds>
PVE_API_URL=<example: https://10.1.1.100:8006/api2/json>
PVE_TEMPLATES_DIR=<directory where templates are saved on node e.g. /mnt/pve/local/template/cache>
```

> **Note:** As of v1.1.0, per-node IP variables (`PVE_NODE_IP_<NODE-NAME>`) are required for service deployments that specify a `target_node`. `PVE_NODE_IP` is still used as the default for templates and cluster-wide lookups.

## Repository Structure

```
├── ansible/
│   ├── ansible.cfg
│   └── common/               # Shared ansible playbooks used across services
├── base-templates/           # Reusable LXC base images that services build on top of
├── services/                 # Individual service configurations/data - essentially mini repos
├── terraform/
│   └── modules/
│       └── lxc/              # Reusable Terraform module for provisioning LXCs
└── .gitea/
    ├── actions/              # Reusable composite actions
    └── workflows/
        ├── base-templates/   # Workflows for building base template LXCs
        ├── common/           # Reusable callable workflows
        └── services/         # Per-service workflows
```

Each service under `services/` follows this structure:
```
services/<name>/
├── ansible/
│   ├── <playbook>.yaml       # Ansible playbooks for provisioning/updating/managing/migrating
│   └── vault.yaml            # Ansible-vault encrypted secrets (if needed)
├── docker-compose.yaml       # (optional) Docker Compose config
└── ...                       # Any other service-specific config files
```

## Usage

### Base Templates
Base templates are reusable LXC images that service templates build on top of (e.g. `docker-debian12`, `postgres17-debian12`). Their ansible playbooks live in `base-templates/<name>/` and their workflows in `.gitea/workflows/base-templates/<name>/template.yaml`.

### Adding a new service template
1. Create a service directory at `services/<name>/`
2. Add an ansible playbook at `services/<name>/ansible/<name>-template.yaml` with `hosts: lxc`
3. Add a workflow at `.gitea/workflows/services/<name>/template.yaml` that calls `.gitea/workflows/common/lxc-template.yaml`:

```yaml
jobs:
  create-template:
    uses: ./.gitea/workflows/common/lxc-template.yaml
    with:
      playbook: services/<name>/ansible/<name>-template.yaml
      lxc_name: <name>
      template_name: <name>-debian12
      base_template: docker-debian12.tar.gz  # or another base template
      enable_docker: true # whether to enable keyctl and nesting features in the lxc to allow docker
      unprivileged: true
    secrets: inherit
```

### Deploying a service LXC
Create a workflow at `.gitea/workflows/services/<name>/lxc.yaml` that calls `.gitea/workflows/common/lxc-terraform.yaml`:

```yaml
jobs:
  deploy:
    uses: ./.gitea/workflows/common/lxc-terraform.yaml
    with:
      target_node: <PVE node name>
      lxc_name: <name>
      base_template: <name>-debian12.tar.gz
      vmid: "<vmid>"
      ip: "10.1.1.<x>/24"
      memory: "2048"
      cores: "1"
      storage_size: "16G"
      enable_docker: true
      unprivileged: true
    secrets: inherit
```

The `target_node` value determines which physical Proxmox node the LXC is deployed on. On non-`main` branches, all deployments are automatically redirected to the dev node regardless of `target_node`.

### Destroying a service LXC
Trigger `.gitea/workflows/common/lxc-destroy.yaml` manually via `workflow_dispatch`. You will be prompted for the LXC name and must type the current branch name as confirmation to proceed.

### Running arbitrary playbooks
The `.gitea/workflows/common/lxc-ansible.yaml` workflow can be called to run arbitrary ansible playbooks from a service's `ansible` folder. Just provide the name of the lxc and the path to the playbook to be run. This can be called multiple times from a caller workflow to run any number of playbooks.

LXC lookup is now cluster-aware: the workflow resolves which node an LXC is running on automatically and targets that node for SSH and Ansible inventory.

### Migrating a service
Migration playbooks live at `services/<name>/ansible/<name>-migration.yaml` and are triggered manually via `.gitea/workflows/services/<name>/migration.yaml`. Migration workflows are kept entirely separate from deployment workflows and are never triggered automatically.

## Development Workflow
- **Feature branches** — LXC templates build and are left running on success for verification, but are not dumped to a template file. Any failure destroys the LXC. LXC deploy jobs will only run `terraform plan` with no apply stage. Dev PVE infrastructure is used.
- **Dev branch** — Templates are dumped to a file and always destroyed afterwards. Dev PVE infrastructure is used.
- **Main branch** — Templates are dumped to a file and always destroyed afterwards. Production PVE infrastructure is used.

### Proxy

The `services/traefik` folder contains a customizable reverse proxy setup. It quickly stands up a traefik instance that uses a docker socket proxy for security, configures crowdsec to monitor for malicious activity - automatically registering a cloudflare bouncer and a traefik bouncer, and an authelia instance for authentication with a postgres/redis backend to allow for scaling, an SMTP setup for emailing password resets, and Duo integration for 2-factor-authentication via push notification.

When adding new services, add them to `services/traefik/routes.yaml` and the `update-proxy-config` workflow will apply changes automatically on push to `main` or `dev`. Routes are rendered dynamically — prod and dev IPs are resolved at build time from the routes file.

All of the static/dynamic/middlewares configurations are in the `services/traefik/rules` folder. `external-routes.yaml` is generated dynamically from `routes.yaml` — do not edit it directly.

Authelia configs will be jinja rendered with the correct secrets/variables before building. Access_control rules can be added to `access_control.yaml` and encrypted with `ansible-vault` (because some of my ACL's are none of your business). They will get decrypted when building using the `ANSIBLE_VAULT_PASSWORD` repository secret.

All the other variables and secrets for traefik and supporting apps can also be stored in an ansible-vault encrypted `vault.yaml` file.

Required vault.yaml vars:
```
DOMAIN:
CF_EMAIL:
CF_API_KEY:
AUTHELIA_JWT_SECRET:
AUTHELIA_SESSION_SECRET:
CF_BOUNCER_TOKEN:
TZ:
AUTHELIA_ADMIN_ID:
AUTHELIA_ADMIN_NAME:
AUTHELIA_ADMIN_EMAIL:
AUTHELIA_ADMIN_PASS:
AUTHELIA_PG_ENCRYPTION_KEY:
AUTHELIA_PG_PASS:
AUTHELIA_PG_USER:
AUTHELIA_PG_DB:
SMTP_USERNAME:
SMTP_HOST:
SMTP_SENDER_EMAIL:
DUO_HOSTNAME:
DUO_INTEGRATION_KEY:
DUO_SECRET_KEY:
```

### Adding a route to the proxy

Add an entry to `services/traefik/routes.yaml`:

```yaml
services:
  myservice:
    subdomain: myservice
    prod_ip: 10.1.1.X
    dev_ip: 10.1.1.Y
    port: 8080
    middleware: chain-authelia@file
```

Pushing this file or `docker-compose.yaml` to `main` or `dev` triggers the `update-proxy-config` workflow automatically.