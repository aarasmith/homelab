module "postgres17_template" {
  source     = "../../../terraform/modules/lxc-template"
  node_name  = "mother"
  hostname   = "postgres17"
  ostemplate = "local:vztmpl/debian-12-standard_12.0-1_amd64.tar.zst"
}
