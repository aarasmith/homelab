# homelab
This repository is for provisioning local/cloud infrastructure with terraform on Proxmox/AWS and building/deploying/managing it with ansible. Everything is orchestrated by and runs on CI/CD using the `gitea-runner-tools` container from the `runners` repo.
## Prerecs
### CI/CD runner image
You must specify in the `lxc-template.yaml` workflow a container image that has terraform, ansible, and nodejs installed. Example:
```
runs-on: ubuntu-latest
container:
    image: git.arasmith.org/admin/gitea-runner-tools:latest
```
### Secrets
The following repo secrets are required:

```
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
GATEWAY=<the network gateway ip>
TEMPLATES_DIR=<directory where templates are saved on node e.g. /mnt/pve/local/template/cache
PVE_NODE_IP=<ip address of the proxmox node you're building on>
PVE_DISK_STORAGE=<the storage for the lxc disks>
PVE_NODE_NAME=<name of the node to build on>
PVE_API_URL=<example: https://10.1.1.100:8006/api2/json>
```

## Usage
### Templates
To create a new lxc template, add an ansible playbook to the `ansible/lxc-template` folder named `<service>-template.yaml`. Ensure that the `hosts` field is `lxc_template`. Also add the following line at the end of the playbook:
```
- import_playbook: ../common/dump-lxc-to-template.yaml
```
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