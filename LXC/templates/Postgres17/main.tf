module "postgres17_template" {
  source     = "../../../terraform/modules/lxc-template"
  node_name  = "{{ PVE_NODE_NAME }}"
  hostname   = "postgres17"
  ostemplate = "truenas:vztmpl/debian-12-standard_12.2-1_amd64.tar.zst"
  vmid       = "{{ POSTGRES17_VMID }}"
  ip         = "{{ POSTGRES17_IP }}/24"

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