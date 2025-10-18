# homelab
This repository is for provisioning local/cloud infrastructure with terraform on Proxmox/AWS and building/deploying/managing it with ansible. Everything is orchestrated by and runs on CI/CD using the `gitea-runner-tools` container from the `runners` repo.
## Prerecs
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
PVE_PASSWORD=<proxmox password>
LXC_PASSWORD=<password for LXC's>
MASTER_SSH_PUBLIC_KEY=<public key to place on built infra>
MASTER_SSH_PRIVATE_KEY=<private key to access built infra>
```

Ensure that the public key is also added to the PVE host as ansible needs to run a few commands on the host to dump template builder LXCs to a vzdump and rename the file.

### Variables
The following repo variables are required:

```
AWS_REGION=<aws region for backend bucket/any aws infra>
AWS_TF_BACKEND_BUCKET=<pre-existing S3 bucket name for your terraform state files>
GATEWAY=<the network gateway ip>
TEMPLATES_DIR=<directory where templates are saved on node e.g. /mnt/pve/local/template/cache
RUNNER_IMAGE=<address of image for actions runner e.g. git.arasmith.org/admin/gitea-runner-tools:latest>
PVE_NODE_IP=<ip address of the proxmox node you're building on>
PVE_DISK_STORAGE=<the storage for the lxc disks>
PVE_NODE_NAME=<name of the node to build on>
PVE_API_URL=<example: https://10.1.1.100:8006/api2/json>
```

## Usage
### Templates
To create a new lxc template for a service, add an ansible playbook to the `ansible/<service>` folder named `<service>-template.yaml`. Ensure that the `hosts` field is `lxc_template`.

Now copy an existing template workflow and save a new `<service>-template.yaml` workflow. Change the `paths` for the ansible template and the workflow like in this:
```
paths:
    - "ansible/<service>/<service>-template.yaml"
    - ".gitea/workflows/<service>/<service>-template.yaml"
```

Change the inputs as necessary
```
with:
    lxc-name: docker #name of the service
    template-name: docker-debian12 #this is what the template will be saved as
    ostemplate: local:vztmpl/debian-12-standard_12.12-1_amd64.tar.zst #the base template to start with
    unprivileged: true #whether the lxc should be unprivileged
    enable_docker: true #whether to enable keyctl and nesting features in the lxc to allow docker
```

### LXC's
The simplest way to provision and deploy LXC's is to create a template that includes all your setup via ansible and then creating another workflow that calls the common `lxc-terraform.yaml` workflow located in the `.gitea/workflows/common` folder. This workflow should be saved as `.gitea/workflows/<service>/<service>-lxc.yaml`.

The `lxc-terraform` workflow takes the following arguments:
```
  target_node   = <Name of the node to build on>
  lxc_name      = <Name of the service>
  base_template = <lbase OS template e.g. "docker-debian12.tar.gz">
  vmid          = <vmid - null for auto assign>
  ip            = <static IP CIDR for the LXC e.g. "10.1.1.100/24">
  memory        = <RAM in MB>
  cores         = <CPU cores available to LXC>
  storage_size  = <e.g. "16G">
  enable_docker = <true/false enable keyctl and nesting>
  unprivileged  = <true/false should LXC be unprivileged>
```

### Proxy

The `ansible/traefik` folder contains a customizable reverse proxy setup. It quickly stands up a traefik instance that uses a docker socket proxy for security, configures crowdsec to monitor for malicious activity and automatically registers a cloudflare bouncer and a traefik bouncer, and an authelia instance for authentication with a postgres/redis backend to allow for scaling, an SMTP setup for emailing password resets, and Duo integration for 2-factor-authentication via push notification.

All of the static/dynamic/middlewares configurations are in the `./rules` folder along with external-routes.yaml for the actual reverse proxying rules/routes.

Authelia configs will be jinja rendered with the correct secrets/variables before building. Access_control rules can be added to `access_control.yaml` and encrypted with `ansible-vault` (because some of my ACL's are none of your business). They will get decrypted when building using the `ANSIBLE_VAULT_PASSWORD` repository secret.

All the other variables and secrets for traefik and supporting apps can also be stored in an ansible-vault encrypted `vault.yaml` file

required vault.yaml vars:
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
### Development workflow
When working out of feature branches, LXC templates will build and not destroy when successful so that they can be verified. However it will not dump to a template file. If any step fails it will destroy the LXC. In the dev and main branches it will dump to a template file and always be destroyed afterwards. Dev and feature branches will use repo secrets and variables suffixed with `_DEV`
