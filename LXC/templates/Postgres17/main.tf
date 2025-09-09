module "postgres17_template" {
  source     = "../../../terraform/modules/lxc-template"
  node_name  = "mother"
  hostname   = "postgres17"
  ostemplate = "local:vztmpl/debian-12-standard_12.0-1_amd64.tar.zst"

  proxmox_api_url = var.proxmox_api_url
  proxmox_user    = var.proxmox_user
  proxmox_password= var.proxmox_password
  lxc_password    = var.lxc_password
  ssh_public_key  = var.ssh_public_key
}
