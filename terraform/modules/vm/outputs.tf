output "vmid" {
  value = proxmox_vm_qemu.vm.vmid
}

output "ip_address" {
  value = var.ip_address
}

output "agent_ip" {
  description = "IP reported by the QEMU guest agent (empty until it checks in)"
  value       = proxmox_vm_qemu.vm.default_ipv4_address
}