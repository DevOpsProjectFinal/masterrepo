# variables.tf

variable "create" {
  description = "Controls if resources should be created (affects nearly all resources)"
  type        = bool
  default     = true
}

variable "create_iam_role" {
  description = "Determines whether an IAM role is created"
  type        = bool
  default     = true
}

variable "iam_role_name" {
  description = "Name of the IAM role"
  type        = string
  default     = "KarpenterController"
}

variable "iam_role_use_name_prefix" {
  description = "Determines whether the name of the IAM role (`iam_role_name`) is used as a prefix"
  type        = bool
  default     = true
}

variable "iam_role_description" {
  description = "IAM role description"
  type        = string
  default     = "Karpenter controller IAM role"
}

variable "iam_role_max_session_duration" {
  description = "Maximum API session duration in seconds between 3600 and 43200"
  type        = number
  default     = null
}

variable "iam_role_permissions_boundary_arn" {
  description = "Permissions boundary ARN to use for the IAM role"
  type        = string
  default     = null
}

variable "iam_role_tags" {
  description = "A map of additional tags to add the the IAM role"
  type        = map(any)
  default     = {}
}

variable "iam_policy_name" {
  description = "Name of the IAM policy"
  type        = string
  default     = "KarpenterController"
}

variable "iam_policy_use_name_prefix" {
  description = "Determines whether the name of the IAM policy (`iam_policy_name`) is used as a prefix"
  type        = bool
  default     = true
}

variable "iam_policy_path" {
  description = "Path of the IAM policy"
  type        = string
  default     = "/"
}

variable "iam_policy_description" {
  description = "IAM policy description"
  type        = string
  default     = "Karpenter controller IAM policy"
}

variable "iam_policy_statements" {
  description = "A list of IAM policy [statements](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document#statement) - used for adding specific IAM permissions as needed"
  type        = any
  default     = []
}

variable "iam_role_policies" {
  description = "Policies to attach to the IAM role in `{'static_name' = 'policy_arn'}` format"
  type        = map(string)
  default     = {}
}

variable "ami_id_ssm_parameter_arns" {
  description = "List of SSM Parameter ARNs that Karpenter controller is allowed read access (for retrieving AMI IDs)"
  type        = list(string)
  default     = []
}

variable "enable_pod_identity" {
  description = "Determines whether to enable support for EKS pod identity"
  type        = bool
  default     = true
}

# TODO - make v1 permssions the default policy at next breaking change
variable "enable_v1_permissions" {
  description = "Determines whether to enable permissions suitable for v1+ (`true`) or for v0.33.x-v0.37.x (`false`)"
  type        = bool
  default     = false
}

variable "iam_role_path" {
  description = "Path of the IAM role"
  type        = string
  default     = "/"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {ENV = "dev"}
}

variable "aws_region" {
  description = "AWS region to deploy EKS"
  default     = "us-east-1"
}

variable "region_alias" {
  description = "AWS region to alias"
  default     = "virginia"
}

variable "cluster_version" {
  description = "EKS Cluster version"
  default     = "1.31"
}

variable "instance_type" {
  description = "Type of instance to use"
  type        = string
  default     = "t2.micro"
}

variable "control_plane_subnet_ids" {
  description = "List of subnet IDs for the EKS control plane"
  type        = list(string)
  default     = []
}

variable "subnet_ids" {
  description = "List of subnet IDs for the EKS cluster"
  type        = list(string)
  default     = []
}

variable "vpc_name" {
  description = "VPC name"
  default     = "vpc-devops-project-eks-cluster"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones for subnets"
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "private_subnets" {
  description = "Private subnets CIDR blocks"
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "public_subnets" {
  description = "Public subnets CIDR blocks"
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

variable "cluster_name" {
  description = "EKS cluster to test deployments for multiple services"
  default     = "devops-project-eks-cluster"
}

variable "account_id" {
  description = "AWS account ID"
  type        = string
  default     = "796973482644"
}

################################################################################
# IAM Role for Service Account (IRSA)
################################################################################

variable "enable_irsa" {
  description = "Determines whether to enable support for IAM role for service accounts"
  type        = bool
  default     = false
}

variable "irsa_oidc_provider_arn" {
  description = "OIDC provider arn used in trust policy for IAM role for service accounts"
  type        = string
  default     = ""
}

variable "irsa_namespace_service_accounts" {
  description = "List of `namespace:serviceaccount`pairs to use in trust policy for IAM role for service accounts"
  type        = list(string)
  default     = ["karpenter:karpenter"]
}

variable "irsa_assume_role_condition_test" {
  description = "Name of the [IAM condition operator](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_elements_condition_operators.html) to evaluate when assuming the role"
  type        = string
  default     = "StringEquals"
}

################################################################################
# Pod Identity Association
################################################################################
# TODO - Change default to `true` at next breaking change
variable "create_pod_identity_association" {
  description = "Determines whether to create pod identity association"
  type        = bool
  default     = false
}

variable "namespace" {
  description = "Namespace to associate with the Karpenter Pod Identity"
  type        = string
  default     = "kube-system"
}

variable "service_account" {
  description = "Service account to associate with the Karpenter Pod Identity"
  type        = string
  default     = "karpenter"
}

################################################################################
# Node Termination Queue
################################################################################

variable "enable_spot_termination" {
  description = "Determines whether to enable native spot termination handling"
  type        = bool
  default     = true
}

variable "queue_name" {
  description = "Name of the SQS queue"
  type        = string
  default     = null
}

variable "queue_managed_sse_enabled" {
  description = "Boolean to enable server-side encryption (SSE) of message content with SQS-owned encryption keys"
  type        = bool
  default     = true
}

variable "queue_kms_master_key_id" {
  description = "The ID of an AWS-managed customer master key (CMK) for Amazon SQS or a custom CMK"
  type        = string
  default     = null
}

variable "queue_kms_data_key_reuse_period_seconds" {
  description = "The length of time, in seconds, for which Amazon SQS can reuse a data key to encrypt or decrypt messages before calling AWS KMS again"
  type        = number
  default     = null
}

################################################################################
# Node IAM Role
################################################################################

variable "create_node_iam_role" {
  description = "Determines whether an IAM role is created or to use an existing IAM role"
  type        = bool
  default     = true
}

variable "cluster_ip_family" {
  description = "The IP family used to assign Kubernetes pod and service addresses. Valid values are `ipv4` (default) and `ipv6`. Note: If `ipv6` is specified, the `AmazonEKS_CNI_IPv6_Policy` must exist in the account. This policy is created by the EKS module with `create_cni_ipv6_iam_policy = true`"
  type        = string
  default     = "ipv4"
}

variable "node_iam_role_arn" {
  description = "Existing IAM role ARN for the IAM instance profile. Required if `create_iam_role` is set to `false`"
  type        = string
  default     = null
}

variable "node_iam_role_name" {
  description = "Name to use on IAM role created"
  type        = string
  default     = null
}

variable "node_iam_role_use_name_prefix" {
  description = "Determines whether the IAM role name (`iam_role_name`) is used as a prefix"
  type        = bool
  default     = true
}

variable "node_iam_role_path" {
  description = "IAM role path"
  type        = string
  default     = "/"
}

variable "node_iam_role_description" {
  description = "Description of the role"
  type        = string
  default     = null
}

variable "node_iam_role_max_session_duration" {
  description = "Maximum API session duration in seconds between 3600 and 43200"
  type        = number
  default     = null
}

variable "node_iam_role_permissions_boundary" {
  description = "ARN of the policy that is used to set the permissions boundary for the IAM role"
  type        = string
  default     = null
}

variable "node_iam_role_attach_cni_policy" {
  description = "Whether to attach the `AmazonEKS_CNI_Policy`/`AmazonEKS_CNI_IPv6_Policy` IAM policy to the IAM IAM role. WARNING: If set `false` the permissions must be assigned to the `aws-node` DaemonSet pods via another method or nodes will not be able to join the cluster"
  type        = bool
  default     = true
}

variable "node_iam_role_additional_policies" {
  description = "Additional policies to be added to the IAM role"
  type        = map(string)
  default     = {}
}

variable "node_iam_role_tags" {
  description = "A map of additional tags to add to the IAM role created"
  type        = map(string)
  default     = {}
}

################################################################################
# Access Entry
################################################################################

variable "create_access_entry" {
  description = "Determines whether an access entry is created for the IAM role used by the node IAM role"
  type        = bool
  default     = true
}

variable "access_entry_type" {
  description = "Type of the access entry. `EC2_LINUX`, `FARGATE_LINUX`, or `EC2_WINDOWS`; defaults to `EC2_LINUX`"
  type        = string
  default     = "EC2_LINUX"
}

################################################################################
# Node IAM Instance Profile
################################################################################

variable "create_instance_profile" {
  description = "Whether to create an IAM instance profile"
  type        = bool
  default     = false
}

################################################################################
# Event Bridge Rules
################################################################################

variable "rule_name_prefix" {
  description = "Prefix used for all event bridge rules"
  type        = string
  default     = "Karpenter"
}

variable "KarpenterInstanceProfile" {
  description = "The instance profile for Karpenter"
  type        = string
  default     = "KarpenterInstanceProfile"
}

variable "create_nat_eips" {
  description = "Check wether to create EIPs or not"
  type        = bool
  default     = false
}
