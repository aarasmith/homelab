provider "aws" {}

terraform {
  backend "s3" {
    key = "homelab.tfstate"
  }
}

module "arr" {
  source     = "./modules/lxc/"
  pm_node_name  = "mother"
  hostname   = "arr"
  ostemplate = "truenas:vztmpl/docker-debian12.tar.gz"
  vmid       = "301"
  ip         = "10.1.1.20/24"
  gateway = var.gateway
  memory = 2048
  cores = 1
  storage = var.storage
  storage_size = "16G"
  enable_docker = true
  unprivileged = true

  pm_api_url = var.pm_api_url
  pm_user    = var.pm_user
  pm_password = var.pm_password
  lxc_password    = var.lxc_password
  ssh_public_key  = var.ssh_public_key
}