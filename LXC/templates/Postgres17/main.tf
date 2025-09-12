module "postgres17_template" {
  source     = "../../../terraform/modules/lxc-template"
  hostname   = var.hostname
  ostemplate = var.ostemplate
  node_name  = var.pm_node_name
  vmid       = null
  ip         = "dhcp"

  pm_api_url = var.pm_api_url
  pm_user    = var.pm_user
  pm_password = var.pm_password
  lxc_password    = var.lxc_password
  ssh_public_key  = var.ssh_public_key
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

variable "hostname" {
  description = "Proxmox node name"
  type        = string
}

variable "ostemplate" {
  description = "Proxmox node name"
  type        = string
}

variable "pm_node_name" {
  description = "Proxmox node name"
  type        = string
}

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