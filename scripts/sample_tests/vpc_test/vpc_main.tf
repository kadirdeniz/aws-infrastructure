module "vpc" {
  source = "../../../terraform/modules/vpc"

  environment = "dev"
  project     = "example"
  owner       = "test-user"

  vpc_cidr = "10.0.0.0/16"
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.101.0/24", "10.0.102.0/24"]
  azs = ["eu-central-1a", "eu-central-1b"]

  tags = {
    Test = "true"
  }
} 