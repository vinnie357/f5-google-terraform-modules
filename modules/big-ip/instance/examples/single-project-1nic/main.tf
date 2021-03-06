# Example Terraform to create a single-NIC instance of BIG-IP using default
# compute service account, and a Marketplace PAYG image.

# Only supported on Terraform 0.12
terraform {
  required_version = "~> 0.12"
}

module "instance" {
  #source              = "https://github.com/memes/f5-google-terraform-modules/modules/big-ip/instance?ref=v1.0.0"
  source                            = "../../"
  project_id                        = var.project_id
  zone                              = var.zone
  service_account                   = var.service_account
  external_subnetwork               = var.subnet
  image                             = var.image
  allow_phone_home                  = false
  allow_usage_analytics             = false
  admin_password_secret_manager_key = var.admin_password_key
}
