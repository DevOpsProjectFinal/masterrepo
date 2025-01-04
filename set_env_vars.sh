#!/bin/bash

# Function to extract and validate Terraform output
get_terraform_output() {
  local output_name=$1
  local output_value

  output_value=$(terraform output -raw "$output_name" 2>/dev/null || echo "")
  
  # Check for invalid characters in the output
  if [[ $output_value =~ [^a-zA-Z0-9_\-] ]]; then
    echo "Warning: Invalid characters detected in $output_name output"
    output_value=""
  fi

  echo "$output_value"
}

# Extract Terraform outputs and set them as environment variables
VPC_ID=$(get_terraform_output "vpc_id")
EKS_CLUSTER_NAME=$(get_terraform_output "eks_cluster_name")
KMS_KEY_ID=$(get_terraform_output "kms_key_id")
LOG_GROUP_NAME=$(get_terraform_output "log_group_name")

# Export the variables to the GitHub Actions environment file
if [ -n "$VPC_ID" ]; then
  echo "VPC_ID=${VPC_ID}" >> $GITHUB_ENV
else
  echo "Warning: VPC_ID output not found or invalid"
fi

if [ -n "$EKS_CLUSTER_NAME" ]; then
  echo "EKS_CLUSTER_NAME=${EKS_CLUSTER_NAME}" >> $GITHUB_ENV
else
  echo "Warning: EKS_CLUSTER_NAME output not found or invalid"
fi

if [ -n "$KMS_KEY_ID" ]; then
  echo "KMS_KEY_ID=${KMS_KEY_ID}" >> $GITHUB_ENV
else
  echo "Warning: KMS_KEY_ID output not found or invalid"
fi

if [ -n "$LOG_GROUP_NAME" ]; then
  echo "LOG_GROUP_NAME=${LOG_GROUP_NAME}" >> $GITHUB_ENV
else
  echo "Warning: LOG_GROUP_NAME output not found or invalid"
fi