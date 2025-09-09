resource "proxmox_lxc" "template" {
  hostname     = var.hostname
  ostemplate   = var.ostemplate
  vmid         = null               # let Proxmox auto-assign
  target_node  = var.node_name
  password     = var.lxc_password
  ssh_public_keys = var.ssh_public_key

  memory = 1024
  cores  = 1

  rootfs {
    storage = "local-lvm"
    size    = "8G"
  }

  network {
    name     = "eth0"
    bridge   = "vmbr0"
    ip       = "dhcp"
    firewall = false
  }

  unprivileged = true

  features {
    nesting = true
  }
}
