################################################################################
# Cluster
################################################################################

output "cluster_endpoint" {
  description = "Endpoint for your Kubernetes API server"
  value       = "https://DDCF651519C65187EAF462B3FB3EE5B9.gr7.us-east-1.eks.amazonaws.com"
}

output "cluster_name" {
  description = "EKS cluster to test deployments for multiple services"
  value = "devops-project-eks-cluster"
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value = <<EOT
-----BEGIN CERTIFICATE-----
MIIDBTCCAe2gAwIBAgIIJKwPiqKOlA0wDQYJKoZIhvcNAQELBQAwFTETMBEGA1UE
AxMKa3ViZXJuZXRlczAeFw0yNTAxMTAxOTE0NDhaFw0zNTAxMDgxOTE5NDhaMBUx
EzARBgNVBAMTCmt1YmVybmV0ZXMwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEK
AoIBAQDZ/VyZ0mKm/dK//GTEuJ8DT/yHF5SJzAWfsuLIT+GnpEI5+ygdCcAcG1wp
y8R6sBAzaYIKROqpLcfo9b0hbKimLGXxsbi2p2Mgw6gNBl6GlA+HsW+c1mAvlr69
1TTZz91DnwgPr8nYYtZMoO9RscEFcLR1QpKt8Sfd7RqFdMiEOE9Z6DtdIr4OEsxH
IKI2d7BO0m+eqEwiVEkHTkLIk8qKXuN6jVDU1JWIPKU2BJt8OgQpv8Mhyh2g1Rhl
oYchBU38pQKJ99XmKZ26kG+DT8zEyDhcpzodcInDdsYiuy7REDb+gbRBXJ5OsGcJ
J4FGOlQ+mrqLPz+e9uGx5cB+WAqVAgMBAAGjWTBXMA4GA1UdDwEB/wQEAwICpDAP
BgNVHRMBAf8EBTADAQH/MB0GA1UdDgQWBBR8wJd3le0Bfj1OalSpANk73fLZCjAV
BgNVHREEDjAMggprdWJlcm5ldGVzMA0GCSqGSIb3DQEBCwUAA4IBAQAhNP/GqdTY
6ApRSwFjsSDBLmhuBoguPXUZKkFYYwwwWILxw5lEK42vkara4+rEtEe3D/qxE/wA
3ONrGzoGVK2bC6K3H3p4g0lMoPPTKeWDOmOZjf8uUH7CIVEJmalaiviDZIaX5qfj
MWYfbYMrrKS7GD5VSNRW4Rw/6UBfkRgEnxKZMg1Qzrikc1K5vymftuuhb3sDQ+Ko
serArClEQRj6jEr1qT+Ymdmn37rsWrZ3kULT/U3n7efcd3Db0/iai1oXeikLXo9L
5+C0S8csMIhbBHx96SX7kMCHl+SgxTBwczDtsRc3Q0XRy7E5vj/DJsLmR2tRTDTN
0SO4GDjFQrmT
-----END CERTIFICATE-----
EOT
}

output "region" {
  description = "AWS region to deploy EKS"
  value = var.aws_region
}

output "KarpenterInstanceProfile" {
  value = var.KarpenterInstanceProfile
}