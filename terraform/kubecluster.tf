locals {                                                    #Static values for k8s cluster
  cluster_name                  = "test-kubecluster"
  k8s_service_account_namespace = "kube-system"
  k8s_service_account_name      = "cluster-autoscaler-aws-cluster-autoscaler"
}

data "aws_caller_identity" "current" {}

module "eks" {                                               #Setting up k8s cluster
  source                        = "terraform-aws-modules/eks/aws"
  cluster_name                  = local.cluster_name
  subnets                       = module.vpc.private_subnets
  manage_aws_auth               = true
  vpc_id                        = module.vpc.vpc_id
  enable_irsa                   = true
  cluster_version               = "1.17"
  worker_groups = [
    {
      name                          = "worker-group-1"
      instance_type                 = "t2.small"
      additional_userdata           = "echo foo bar"
      asg_desired_capacity          = 2
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]
      tags = [
        {
          "key"                 = "k8s.io/cluster-autoscaler/enabled"
          "propagate_at_launch" = "false"
          "value"               = "true"
        },
        {
          "key"                 = "k8s.io/cluster-autoscaler/${local.cluster_name}"
          "propagate_at_launch" = "false"
          "value"               = "true"
        }
      ]
    }
  ]
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}
