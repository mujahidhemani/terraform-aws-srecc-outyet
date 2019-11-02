provider "aws" {
  
}

module "srecc-vpc" {
  source  = "mujahidhemani/srecc-vpc/aws"
  version = "1.0.1"
}


module "srecc-ec2-autoscale" {
  source  = "mujahidhemani/srecc-ec2-autoscale/aws"
  version = "1.0.0"
  vpc_id = "${module.srecc-vpc.vpc_id}"
  subnet_ids = "${module.srecc-vpc.all_subnet_ids}"
}

