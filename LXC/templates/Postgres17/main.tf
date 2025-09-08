variable "lxc_password" {
        type = string
        sensitive = true
}

variable "ssh_public_key" {
  description = "The SSH public key to be added to the LXC container"
  type        = string
  sensitive = true
}


resource "proxmox_lxc" "basic" {
    target_node  = "mother"
    hostname     = "lxc-template"
    ostemplate   = "truenas:vztmpl/debian-12-standard_12.2-1_amd64.tar.zst"
    password     = var.lxc_password
    unprivileged = true
    vmid = 999
    start = true
    memory = 2048
    ssh_public_keys = var.ssh_public_key
    // Terraform will crash without rootfs defined
    rootfs {
        storage = "leroy-storage"
        size    = "16G"
    }

    features {
        nesting = true
        keyctl  = true
    }

    network {
        name   = "eth0"
        bridge = "vmbr0"
        ip     = "10.1.1.250/24"
        gw     = "10.1.1.1"
    }
}