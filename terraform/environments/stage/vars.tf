variable "nat_gateway" {
  type        = bool
  default     = false
  description = "A boolean flag to deploy NAT Gateway."
}

variable "vpc_name" {
  type        = string
  nullable    = false
  description = "Name of the VPC."
}

variable "region" {
  type        = string
  nullable    = false
  description = "Aws region"
}

variable "environment" {
  type        = string
  nullable    = false
  description = "environment type"
}

variable "cidr_block" {
  type        = string
  default     = "10.0.0.0/16"
  description = "The IPv4 CIDR block for the VPC."

  validation {
    condition     = can(cidrnetmask(var.cidr_block))
    error_message = "Must be a valid IPv4 CIDR block address."
  }
}

variable "enable_dns_support" {
  type        = bool
  default     = true
  description = "A boolean flag to enable/disable DNS support in the VPC."
}

variable "enable_dns_hostnames" {
  type        = bool
  default     = false
  description = "A boolean flag to enable/disable DNS hostnames in the VPC."
}

variable "default_tags" {
  type        = map(string)
  default     = {}
  description = "A map of tags to add to all resources."
}

variable "private_subnets" {
  description = "List of private subnets"
  type = list(object({
    name  = string
    cidr  = string
    az    = string
  }))
  default = []
}

variable "public_subnets" {
  description = "List of public subnets"
  type = list(object({
    name  = string
    cidr  = string
    az    = string
  }))
  default = []
}

variable "cluster_name" {
  type        = string
  description = "EKS cluster name"
}

variable "managed_node_groups" {
  description = "Map of maps specifying managed node groups"
  type = object({
    name           = string
    desired_size   = number
    min_size       = number
    max_size       = number
    instance_types = list(string)
  })
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

variable "eks_endpoint_public_access" {
  type    = bool
  default = false
}

variable "eks_endpoint_private_access" {
  type    = bool
  default = true
}

variable "eks_version" {
  description = "The version of eks cluster"
  type        = string
  default     = "latest"
}

variable "dev_access_namespaces" {
  type = object({
    k8s_group_name: string
    iam_group: string
    iam_group_arn: string
    namespaces : list(string)
    api_groups = list(string)
    resources  = list(string)
    verbs      = list(string)
  })
}

variable "jenkins_pipeline_access_namespaces" {
    type = object({
      k8s_user_name: string
      iam_user: string
      iam_user_arn: string
      namespaces : list(string)
      api_groups = list(string)
      resources  = list(string)
      verbs      = list(string)
    })
  }