provider "aws" {

}

provider "cloudflare" {

}

module "srecc-vpc" {
  source  = "mujahidhemani/srecc-vpc/aws"
  version = "1.1.1"
}


module "srecc-ec2-backend" {
  source           = "mujahidhemani/srecc-ec2-autoscale/aws"
  version          = "1.2.0"
  vpc_id           = "${module.srecc-vpc.vpc_id}"
  subnet_ids       = "${module.srecc-vpc.backend_subnet_ids}"
  target_group_arn = "${module.srecc-frontend.target_group_arn}"
}

module "srecc-frontend" {
  source                 = "mujahidhemani/srecc-load-balancer/aws"
  version                = "1.2.0"
  vpc_id                 = "${module.srecc-vpc.vpc_id}"
  subnet_ids             = "${module.srecc-vpc.frontend_subnet_ids}"
  autoscaling_group_name = "${module.srecc-ec2-backend.autoscaling_group_name}"
  backend_app_sg_id      = "${module.srecc-ec2-backend.backend_sg_id}"
  tls_cert_arn           = "${var.tls_cert_arn}"
}

module "srecc-cloudflare-dns" {
  source             = "mujahidhemani/srecc-cloudflare-dns/aws"
  version            = "1.0.0"
  record_type        = "CNAME"
  record_name        = var.cloudflare_dns_record_name
  record_value       = module.srecc-frontend.lb_dns_name
  cloudflare_zone_id = var.cloudflare_zone_id
}
