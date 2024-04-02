####### NETWORK VARS #######

nat_gateway= true
vpc_name= "vpc-non-prod"
cidr_block="10.120.0.0/16"
enable_dns_support= true
enable_dns_hostnames= true
region = "us-east-1"


default_tags = {
  Environment = "Development"
  Project     = "WebApp"
  Owner       = "DevTeam"
}

private_subnets = [
  {
    name  = "private-sn-us-east-1a"
    cidr  = "10.120.1.0/24"
    az    = "us-east-1a"
  },
  {
    name  = "private-sn-us-east-1b"
    cidr  = "10.120.2.0/24"
    az    = "us-east-1b"
  }
]

public_subnets = [
  {
    name  = "public-sn-us-east-1a"
    cidr  = "10.120.3.0/24"
    az    = "us-east-1a"
  },
  {
    name  = "public-sn-us-east-1b"
    cidr  = "10.120.4.0/24"
    az    = "us-east-1b"
  }
]

####### EKS VARS #######

cluster_name = "non-prod-eks"
eks_version = "1.29"
managed_node_groups = {
  demo_group = {
    name           = "non-prod-eks-node-group"
    desired_size   = 2
    min_size       = 1
    max_size       = 3
    instance_types = ["t3a.small"]
  }
}

cluster_addons = ["vpc-cni", "kube-proxy", "coredns", "aws-ebs-csi-driver"]
enabled_cluster_log_types = ["audit", "api", "authenticator","scheduler","controllerManager"]
eks_endpoint_public_access = true
eks_endpoint_private_access = false