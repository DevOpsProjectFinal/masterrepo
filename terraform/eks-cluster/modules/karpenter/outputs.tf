output "karpenter_role_arn" {
  description = "IAM role ARN for Karpenter"
  value       = aws_iam_role.karpenter.arn
}