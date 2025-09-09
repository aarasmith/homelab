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

# Provider creds from credentials.auto.tfvars
variable "proxmox_api_url" { type = string }
variable "proxmox_user"    { type = string }
variable "proxmox_password"{ type = string }
variable "lxc_password"    { type = string }
variable "ssh_public_key"  { type = string }
