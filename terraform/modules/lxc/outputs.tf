output "vmid" {
  value = proxmox_lxc.template.vmid
}

output "ip" {
  value = proxmox_lxc.template.network[0].ip
}
