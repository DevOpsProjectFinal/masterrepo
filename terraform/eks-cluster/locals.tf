locals {
  create_cluster_sg = var.create_cluster_security_group
  create_node_sg    = var.create_node_security_group

  cluster_security_group_id = local.create_cluster_sg ? (length(aws_security_group.cluster) > 0 ? aws_security_group.cluster[0].id : null) : var.cluster_security_group_id
  node_security_group_id    = local.create_node_sg ? (length(aws_security_group.node) > 0 ? aws_security_group.node[0].id : null) : var.node_security_group_id
}