provider "aws" {}

terraform {
  backend "s3" {}
}

locals {
  gateway = "10.1.1.1"
  storage = "leroy-storage"
}


module "arr" {
  source     = "./modules/lxc/"
  pm_node_name  = "mother"
  hostname   = "arr"
  ostemplate = "truenas:vztmpl/docker-debian12.tar.zst"
  vmid       = "301"
  ip         = "10.1.1.20/24"
  gateway = local.gateway
  memory = 2048
  cores = 1
  storage = local.storage
  storage_size = "16G"
  enable_docker = true
  unprivileged = true

  pm_api_url = var.pm_api_url
  pm_user    = var.pm_user
  pm_password = var.pm_password
  lxc_password    = var.lxc_password
  ssh_public_key  = var.ssh_public_key
}