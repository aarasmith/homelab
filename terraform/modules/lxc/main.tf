resource "proxmox_lxc" "template" {
  hostname     = var.hostname
  ostemplate   = var.ostemplate
  vmid         = var.vmid
  target_node  = var.target_node
  password     = var.lxc_password
  start        = true
  ssh_public_keys = var.ssh_public_key

  memory = var.memory
  cores  = var.cores

  rootfs {
    storage = var.storage
    size    = var.storage_size
  }

  network {
    name     = "eth0"
    bridge   = "vmbr0"
    ip       = var.ip
    gw       = var.gateway
  }

  unprivileged = var.unprivileged

  features {
    nesting = var.enable_docker
    keyctl  = var.enable_docker
  }
}
