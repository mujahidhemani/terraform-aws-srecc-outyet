provider "aws" {
  
}

module "srecc-vpc" {
  source  = "mujahidhemani/srecc-vpc/aws"
  version = "1.0.0"
}



