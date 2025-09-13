variable "hostname" {
  type        = string
  description = "Hostname of the container"
}

variable "ostemplate" {
  type        = string
  description = "Path to the OS template (e.g., local:vztmpl/debian-12-standard_12.0-1_amd64.tar.zst)"
}

variable "vmid" {
  type        = number
  description = "vmid for the LXC"
  default = null
}

variable "pm_node_name" {
  type        = string
  description = "The Proxmox node to deploy the container on"
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

variable "memory" {
  type        = number
  description = "memory in MB"
  default     = 2048
}

variable "cores" {
  type        = number
  description = "number of cpu cores to allow"
  default     = 1
}

variable "storage" {
  type        = string
  description = "name of the storage for the LXC disk"
}

variable "storage_size" {
  type        = string
  description = "amount of storage for disk"
  default     = "8G"
}

variable "gateway" {
  type        = string
  description = "network gateway IP address"
}

variable "ip" {
  type        = string
  description = "IP address for the LXC"
  default     = "dhcp"
}

variable "unprivileged" {
  type        = bool
  description = "Should the LXC be unprivileged"
}

variable "enable_docker" {
  description = "Should keyctl and nesting feature flags be on"
  type        = bool
  default     = false
}
