module "networking" {
  source = "../../modules/network"
  nat_gateway= var.nat_gateway
  vpc_name= var.vpc_name
  cidr_block=var.cidr_block
  enable_dns_support= var.enable_dns_support
  enable_dns_hostnames= var.enable_dns_hostnames
  default_tags=var.default_tags
  private_subnets = var.private_subnets
  public_subnets = var.public_subnets
  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
  }
  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
  }
}


