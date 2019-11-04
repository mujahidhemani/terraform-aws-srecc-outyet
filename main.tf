provider "aws" {

}

module "srecc-vpc" {
  source  = "mujahidhemani/srecc-vpc/aws"
  version = "1.0.1"
}


module "srecc-ec2-backend" {
  source           = "mujahidhemani/srecc-ec2-autoscale/aws"
  version          = "1.1.1"
  vpc_id           = "${module.srecc-vpc.vpc_id}"
  subnet_ids       = "${module.srecc-vpc.all_subnet_ids}"
  target_group_arn = "${module.srecc-frontend.target_group_arn}"
}

module "srecc-frontend" {
  source                 = "mujahidhemani/srecc-load-balancer/aws"
  version                = "1.0.1"
  vpc_id                 = "${module.srecc-vpc.vpc_id}"
  subnet_ids             = "${module.srecc-vpc.all_subnet_ids}"
  autoscaling_group_name = "${module.srecc-ec2-backend.autoscaling_group_name}"

}
