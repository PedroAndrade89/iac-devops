module "eks" {
  source = "../../modules/eks"
  region          = var.region
  cluster_name    = var.cluster_name
  private_subnets = module.networking.private_subnets
  public_subnets  = module.networking.public_subnets
  vpc_id          = module.networking.vpc_id
  cluster_addons = var.cluster_addons
  enabled_cluster_log_types =var.enabled_cluster_log_types
  eks_endpoint_public_access = var.eks_endpoint_public_access
  eks_endpoint_private_access = var.eks_endpoint_private_access
  managed_node_groups = var.managed_node_groups
  eks_version = var.eks_version
  dev_access_namespaces var.dev_access_namespaces
  jenkins_pipeline_access_namespaces = var.jenkins_pipeline_access_namespaces
}