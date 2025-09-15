variable "pm_api_url" {
  description = "Proxmox API endpoint"
  type        = string
}

variable "pm_user" {
        type = string
        sensitive = true
}

variable "pm_password" {
        type = string
        sensitive = true
}

variable "lxc_password" {
  description = "Root password for the LXC"
  type        = string
  sensitive   = true
}

variable "ssh_public_key" {
  description = "SSH public key to inject into LXC"
  type        = string
}

variable "gateway" {
  description = "ip address for network gateway"
  type        = string
}

variable "storage" {
  description = "storage for LXC/VM disks"
  type        = string
}

