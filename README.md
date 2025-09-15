# homelab
This repository is for provisioning local/cloud infrastructure with terraform on Proxmox/AWS and building/deploying/managing it with ansible. Everything is orchestrated by and runs on CI/CD using the `gitea-runner-tools` container from the `runners` repo.
## Prerecs
### CI/CD runner image
You must specify in the repo vars as `RUNNER_IMAGE` a container image you have access to that has terraform, ansible, and nodejs installed. Example:
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
To create a new lxc template, add an ansible playbook to the `ansible/lxc-template` folder named `<service>-template.yaml`. Ensure that the `hosts` field is `lxc_template`.

Now copy an existing template workflow and save a new `<service>-template.yaml` workflow. Change the `paths` for the ansible template and the workflow like in this example for a Postgres17 template:
```
paths:
    - "ansible/lxc-template/postgres17-template.yaml"
    - "terraform/modules/lxc-template/**"
    - ".gitea/workflows/postgres17-template.yaml"
```

Change the inputs as necessary
```
with:
    lxc-name: docker #name of the service
    template-name: docker-debian12 #this is what the template will be saved as
    ostemplate: local:vztmpl/debian-12-standard_12.12-1_amd64.tar.zst #the base template to start with
    unprivileged: true #whether the lxc should be unprivileged
```

### LXC's
The simplest way to provision and deploy LXC's is to create a template that includes all your setup via ansible and then deploying this template in the `terraform/main.tf` file. The `main.yaml` workflow will spin up permanent infrastructure based on this configuration.

Change the following inputs depending on what you're deploying:
```
  pm_node_name  = <Name of the node to build on>
  hostname      = <Name of the service>
  ostemplate    = <location of base template e.g. "truenas:vztmpl/docker-debian12.tar.gz">
  vmid          = <vmid - null for auto assign>
  ip            = <static IP for the LXC e.g. "10.1.1.100/24">
  memory        = <RAM in MB>
  cores         = <CPU cores available to LXC>
  storage_size  = <e.g. "16G">
  enable_docker = <true/false enable keyctl and nesting>
  unprivileged  = <true/false should LXC be unprivileged>
```

### Development workflow
When working out of feature branches, LXC templates will build and not destroy when successful so that they can be verified. However it will not dump to a template file. If any step fails it will destroy the LXC. In the main branch it will dump to a template file and always be destroyed afterwards.

For permanent LXC's in the `main.yaml` workflow terraform will only run apply in the main branch. Feature branches will just run `terraform plan`.