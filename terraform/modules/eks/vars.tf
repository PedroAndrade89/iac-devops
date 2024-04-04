variable "region" {
  description = "AWS region"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "public_subnets" {
  description = "Public Subnet IDs for the EKS cluster"
  type        = list(string)
}

variable "private_subnets" {
  description = "Private Subnet IDs for the EKS cluster"
  type        = list(string)
}

variable "default_ami_type" {
  description = "The type of AMI to use for the node group. Valid values: AL2_x86_64, AL2_x86_64_GPU"
  type        = string
  default     = "AL2_x86_64"
}

variable "default_capacity_type" {
  description = "The capacity type for the node group. Valid values: ON_DEMAND, SPOT"
  type        = string
  default     = "SPOT"
}

variable "eks_version" {
  description = "The version of eks cluster"
  type        = string
}

variable "managed_node_groups" {
  description = "Map of maps specifying managed node groups"
  type = map(object({
    name : string
    desired_size : number
    min_size : number
    max_size : number
    instance_types : list(string)
  }))
  default = {}
}

variable "eks_endpoint_public_access" {
  type    = bool
  default = false
}

variable "eks_endpoint_private_access" {
  type    = bool
  default = true
}

variable "cluster_addons" {
  description = "List of strings specifying cluster addons"
  type        = list(string)
  default     = ["vpc-cni", "kube-proxy", "coredns", "aws-ebs-csi-driver"]
}

variable "enabled_cluster_log_types" {
  description = "List of strings specifying cluster log types"
  type        = list(string)
  default     = ["audit", "api", "authenticator"]
}

variable "dev_access_namespaces" {
  type = map(object({
    k8s_group_name: string
    iam_group: string
    iam_group_arn: string
    namespaces : list(string)
    api_groups = list(string)
    resources  = list(string)
    verbs      = list(string)
  }))
}

variable "jenkins_pipeline_access_namespaces" {
    type = map(object({
      k8s_user_name: string
      iam_user: string
      iam_user_arn: string
      namespaces : list(string)
      api_groups = list(string)
      resources  = list(string)
      verbs      = list(string)
    }))
  }
