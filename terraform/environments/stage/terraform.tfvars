####### NETWORK VARS #######

nat_gateway= true
vpc_name= "vpc-non-prod"
environment = "stage"
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
    name           = "non-prod-eks-node-group"
    desired_size   = 2
    min_size       = 0
    max_size       = 5
    max_unavailable = 1
    instance_types = ["t3a.medium"]
}

cluster_addons = ["vpc-cni", "kube-proxy", "coredns", "aws-ebs-csi-driver"]
enabled_cluster_log_types = ["audit", "api", "authenticator","scheduler","controllerManager"]
eks_endpoint_public_access = true
eks_endpoint_private_access = false

dev_access_namespaces = {
  namespaces = ["rms-cte-global-interface", "rms-cte-qapter-claims", "rms-cte-qapter-mobile","rms-cte-qapter-vi"]
  iam_group = "developers-group"
  iam_group_arn = "arn:aws:iam::154396925587:group/developers-group"
  k8s_group_name = "k8s-dev-access-group"
  api_groups = ["", "apps", "extensions"]
  resources  = ["deployments", "services", "replicasets", "replicationcontrollers", "pods", "pods/log", "pods/exec", "endpoints", "persistentvolumes", "configmaps", "secrets", "ingresses", "pvc", "limits", "quota", "sts", "daemonsets", "jobs", "statefulsets"]
  verbs      = ["get", "list", "watch", "create", "delete", "update", "patch"]
}

jenkins_pipeline_access_namespaces = {
  namespaces = ["rms-cte-global-interface", "rms-cte-qapter-claims", "rms-cte-qapter-mobile","rms-cte-qapter-vi"]
  iam_user = "jenkins-k8s-pipelines-user"
  iam_user_arn = "arn:aws:iam::154396925587:user/jenkins-k8s-pipelines-user"
  k8s_user_name = "jenkins_deploy_access_user"
  api_groups = ["", "apps", "extensions"]
  resources  = ["deployments", "services", "replicasets", "replicationcontrollers", "pods", "pods/log", "pods/exec", "endpoints", "persistentvolumes", "configmaps", "secrets", "ingresses", "pvc", "limits", "quota", "sts", "daemonsets", "jobs", "statefulsets"]
  verbs      = ["get", "list", "watch", "create", "delete", "update", "patch"]
}
