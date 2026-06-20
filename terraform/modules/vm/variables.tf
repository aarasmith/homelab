# --- Placement ---
variable "vmid" {
  description = "VMID for the VM (leave null to let Proxmox auto-assign)"
  type        = number
  default     = null
}

variable "vm_name" {
  description = "Hostname/name of the VM"
  type        = string
}

variable "target_node" {
  description = "Proxmox node to deploy the VM on"
  type        = string
}

variable "template_name" {
  description = "Name of the cloud-init template to clone e.g. debian12-cloudinit"
  type        = string
}

variable "full_clone" {
  description = "Whether to perform a full clone (vs linked clone)"
  type        = bool
  default     = true
}

# --- Compute ---
variable "cores" {
  type    = number
  default = 1
}

variable "memory" {
  description = "Memory in MB"
  type        = number
  default     = 2048
}

variable "scsihw" {
  type    = string
  default = "virtio-scsi-single"
}

variable "boot" {
  type    = string
  default = "order=scsi0"
}

variable "agent" {
  description = "Enable QEMU guest agent (1 = enabled, 0 = disabled)"
  type        = number
  default     = 1
}

variable "vm_state" {
  type    = string
  default = "running"
}

variable "automatic_reboot" {
  type    = bool
  default = true
}

# --- Storage ---
variable "cloudinit_storage" {
  description = "Storage for the per-VM cloud-init drive (bootstrap-tier, not the live OS disk) — e.g. truenas in prod, local in dev"
  type        = string
  default     = "local"
}

variable "storage" {
  description = "Storage/datastore name for the disk and cloud-init drive"
  type        = string
}

variable "disk_size" {
  description = "Size of the root disk e.g. 16G (must be >= template disk size)"
  type        = string
  default     = "8G"
}

# --- Networking ---
variable "bridge" {
  type    = string
  default = "vmbr0"
}

variable "ip_address" {
  description = "Static IP in CIDR form e.g. 10.1.1.62/24"
  type        = string
}

variable "gateway" {
  type = string
}

variable "nameserver" {
  type    = string
  default = "1.1.1.1 8.8.8.8"
}

# --- Cloud-init ---
variable "ssh_public_key" {
  type = string
}

variable "ci_user" {
  type    = string
  default = "debian"
}

variable "ci_password" {
  type      = string
  sensitive = true
}

variable "ciupgrade" {
  type    = bool
  default = true
}

variable "cicustom" {
  description = "Optional cicustom snippet ref e.g. vendor=local:snippets/qemu-guest-agent.yml"
  type        = string
  default     = null
}