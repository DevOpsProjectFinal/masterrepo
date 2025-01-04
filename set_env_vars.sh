#!/bin/bash

# Extract Terraform outputs and set them as environment variables
VPC_ID=$(terraform output -raw vpc_id)
EKS_CLUSTER_NAME=$(terraform output -raw eks_cluster_name)
KMS_KEY_ID=$(terraform output -raw kms_key_id)
LOG_GROUP_NAME=$(terraform output -raw log_group_name)

# Export the variables to the GitHub Actions environment file
echo "VPC_ID=${VPC_ID}" >> $GITHUB_ENV
echo "EKS_CLUSTER_NAME=${EKS_CLUSTER_NAME}" >> $GITHUB_ENV
echo "KMS_KEY_ID=${KMS_KEY_ID}" >> $GITHUB_ENV
echo "LOG_GROUP_NAME=${LOG_GROUP_NAME}" >> $GITHUB_ENV