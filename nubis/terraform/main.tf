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

module "backup_rawdata" {
  source       = "github.com/nubisproject/nubis-terraform//bucket?ref=v2.2.0"
  region       = "${var.region_second}"
  environment  = "${var.environment}"
  account      = "${var.account}"
  service_name = "${var.service_name}"
  purpose      = "backup_rawdata"
  role_cnt     = "${length(data.aws_availability_zones.available.names)}"
  role         = "${module.worker.role}"
}
