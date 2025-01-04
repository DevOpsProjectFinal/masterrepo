#!/bin/bash

# Extract Terraform outputs and set them as environment variables
VPC_ID=$(terraform output -raw vpc_id 2>/dev/null || echo "")
EKS_CLUSTER_NAME=$(terraform output -raw eks_cluster_name 2>/dev/null || echo "")
KMS_KEY_ID=$(terraform output -raw kms_key_id 2>/dev/null || echo "")
LOG_GROUP_NAME=$(terraform output -raw log_group_name 2>/dev/null || echo "")

# Check if outputs are found and export them to the GitHub Actions environment file
if [ -n "$VPC_ID" ]; then
  echo "VPC_ID=${VPC_ID}" >> $GITHUB_ENV
else
  echo "Warning: VPC_ID output not found"
fi

if [ -n "$EKS_CLUSTER_NAME" ]; then
  echo "EKS_CLUSTER_NAME=${EKS_CLUSTER_NAME}" >> $GITHUB_ENV
else
  echo "Warning: EKS_CLUSTER_NAME output not found"
fi

if [ -n "$KMS_KEY_ID" ]; then
  echo "KMS_KEY_ID=${KMS_KEY_ID}" >> $GITHUB_ENV
else
  echo "Warning: KMS_KEY_ID output not found"
fi

if [ -n "$LOG_GROUP_NAME" ]; then
  echo "LOG_GROUP_NAME=${LOG_GROUP_NAME}" >> $GITHUB_ENV
else
  echo "Warning: LOG_GROUP_NAME output not found"
fi