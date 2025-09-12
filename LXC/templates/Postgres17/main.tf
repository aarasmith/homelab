module "postgres17_template" {
  source          = "../../../terraform/modules/lxc-template"
  hostname        = var.hostname
  ostemplate      = var.ostemplate
  gateway         = var.gateway
  storage         = var.storage
  node_name       = var.pm_node_name
  unprivileged    = var.unprivileged

  pm_api_url      = var.pm_api_url
  pm_user         = var.pm_user
  pm_password     = var.pm_password
  lxc_password    = var.lxc_password
  ssh_public_key  = var.ssh_public_key
}


variable "hostname" {
  description = "LXC host name"
  type        = string
}

variable "ostemplate" {
  description = "Base os template"
  type        = string
}

variable "storage" {
  type        = string
  description = "name of the storage for the lxc disk"
}

variable "gateway" {
  type        = string
  description = "network gateway IP address"
}

variable "unprivileged" {
  description = "Should the LXC be unprivileged"
  type        = bool
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