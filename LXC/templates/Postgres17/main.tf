module "postgres17_template" {
  source     = "../../../terraform/modules/lxc-template"
  #would maybe change
  node_name  = "mother"
  hostname   = "postgres17"
  ostemplate = "truenas:vztmpl/debian-12-standard_12.2-1_amd64.tar.zst"
  vmid       = "999"
  ip         = "10.1.1.250/24"

  proxmox_api_url = var.proxmox_api_url
  proxmox_user    = var.proxmox_user
  proxmox_password= var.proxmox_password
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

variable "proxmox_api_url" {
  description = "Proxmox API endpoint"
  type        = string
}

variable "proxmox_user" {
  description = "Proxmox user with permissions"
  type        = string
}
#would change - try api token
variable "proxmox_password" {
  description = "Proxmox user password"
  type        = string
  sensitive   = true
}