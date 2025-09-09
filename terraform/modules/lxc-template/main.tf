resource "proxmox_lxc" "template" {
  hostname     = var.hostname
  ostemplate   = var.ostemplate
  vmid         = null               # let Proxmox auto-assign
  target_node  = var.node_name
  password     = var.lxc_password
  start        = true
  ssh_public_keys = var.ssh_public_key

  memory = 2048
  cores  = 1

  rootfs {
    storage = "leroy-storage"
    size    = "16G"
  }

  network {
    name     = "eth0"
    bridge   = "vmbr0"
    ip       = "dhcp"
    gw       = "10.1.1.1"
  }

  unprivileged = true

  features {
    nesting = true
    keyctl  = true
  }
}
