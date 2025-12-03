module "vpc_module" {
  source = "../../modules/vpc"
  vpc_cidr = "10.0.0.0/16"
    public_subnet_cidrs = {
    ap-northeast-1a = "10.0.3.0/24",
    ap-northeast-1c = "10.0.4.0/24",
    ap-northeast-1d = "10.0.5.0/24",
  }
  private_subnet_cidrs = {
    ap-northeast-1a = "10.0.0.0/24",
    ap-northeast-1c = "10.0.1.0/24",
    ap-northeast-1d = "10.0.2.0/24",
  }
  azs = ["ap-northeast-1a","ap-northeast-1c","ap-northeast-1d"]
}