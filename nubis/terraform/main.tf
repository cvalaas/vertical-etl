module "worker" {
  source            = "github.com/nubisproject/nubis-terraform//worker?ref=v2.2.0"
  region            = "${var.region}"
  environment       = "${var.environment}"
  account           = "${var.account}"
  service_name      = "${var.service_name}"
  purpose           = "shell"
  ami               = "${var.ami}"
  ssh_key_file      = "${var.ssh_key_file}"
  ssh_key_name      = "${var.ssh_key_name}"
  nubis_sudo_groups = "${var.nubis_sudo_groups}"
  nubis_user_groups = "${var.nubis_user_groups}"

  root_storage_size = "32"
  instance_type     = "t2.small"
}

module "archive" {
  source       = "github.com/nubisproject/nubis-terraform//bucket?ref=v2.2.0"
  region       = "${var.region}"
  environment  = "${var.environment}"
  account      = "${var.account}"
  service_name = "${var.service_name}"
  purpose      = "archive"
  role         = "${module.worker.role}"
}

module "nagios" {
  source       = "github.com/nubisproject/nubis-terraform//bucket?ref=v2.2.0"
  region       = "${var.region}"
  environment  = "${var.environment}"
  account      = "${var.account}"
  service_name = "${var.service_name}"
  purpose      = "nagios"
  role         = "${module.worker.role}"
}

#XXX: region fix will be released after Nubis v2.2.0 (3fb2ebe3023e18df01667e1c9b43503c0f09bf3c)
#XXX: SSE feature will be released after Nubis v2.2.0 (9ad6e588cc7db80a53725e6a0ea62a8384383d6d)
#XXX: Expiration policies will be released after Nubis v2.2.0 (gozer:da652f880800981e123b2f5621ca3d0c50a5a773)
module "backups" {
  source                    = "github.com/gozer/nubis-terraform//bucket?ref=da652f880800981e123b2f5621ca3d0c50a5a773"
  region                    = "${var.backup_region}"
  environment               = "${var.environment}"
  account                   = "${var.account}"
  service_name              = "${var.service_name}"
  purpose                   = "backups"
  role                      = "${module.worker.role}"
  storage_encrypted_at_rest = true
  expiration_days           = 930

  transitions = {
    GLACIER     = 186
    STANDARD_IA = 60
  }
}
