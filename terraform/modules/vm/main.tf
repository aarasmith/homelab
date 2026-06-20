resource "proxmox_vm_qemu" "vm" {
  vmid        = var.vmid
  name        = var.vm_name
  target_node = var.target_node
  clone       = var.template_name
  full_clone  = var.full_clone

  cpu { 
    cores = var.cores 
  }

  agent            = var.agent
  memory           = var.memory
  boot             = var.boot
  scsihw           = var.scsihw
  vm_state         = var.vm_state
  automatic_reboot = var.automatic_reboot

  cicustom   = var.cicustom
  ciupgrade  = var.ciupgrade
  ciuser     = var.ci_user
  cipassword = var.ci_password
  sshkeys    = var.ssh_public_key

  nameserver = var.nameserver
  ipconfig0  = "ip=${var.ip_address},gw=${var.gateway}"
  skip_ipv6  = true # homelab is IPv4-only (see networking.md)

  serial {
    id = 0
  }

  disks {
    scsi {
      scsi0 {
        disk {
          storage = var.storage           # live disk — leroy-storage / dev-storage
          size    = var.disk_size
        }
      }
    }
    ide {
      ide1 {
        cloudinit {
          storage = var.cloudinit_storage # bootstrap-tier — truenas / local
        }
      }
    }
  }

  network {
    id     = 0
    bridge = var.bridge
    model  = "virtio"
  }
}