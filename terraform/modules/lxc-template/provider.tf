terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = ">= 2.9.14"
    }
  }
}

provider "proxmox" {
  pm_api_url      = var.proxmox_api_url
  pm_user         = var.proxmox_user
  pm_password     = var.proxmox_password
  pm_tls_insecure = true
}

variable "proxmox_api_url" {
  description = "Proxmox API endpoint"
  type        = string
}

variable "proxmox_user" {
  description = "Proxmox user with permissions"
  type        = string
}

variable "proxmox_password" {
  description = "Proxmox user password"
  type        = string
  sensitive   = true
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