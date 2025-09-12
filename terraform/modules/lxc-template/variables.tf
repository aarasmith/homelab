variable "node_name" {
  type        = string
  description = "The Proxmox node to deploy the container on"
}

variable "hostname" {
  type        = string
  description = "Hostname of the container"
}

variable "ostemplate" {
  type        = string
  description = "Path to the OS template (e.g., local:vztmpl/debian-12-standard_12.0-1_amd64.tar.zst)"
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
  type        = bool
  description = "Should the LXC be unprivileged"
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
