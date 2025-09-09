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
