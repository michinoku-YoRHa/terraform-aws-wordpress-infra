module "vpc_module" {
  source = "../../modules/vpc"
  vpc_cidr = "10.0.0.0/16"
  private_subnet_cidr_1a = "10.0.0.0/24"
}