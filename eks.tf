module "eks" {
  source       = "terraform-aws-modules/eks/aws"
  cluster_name    = var.cluster_name
  cluster_version = "1.19"
  subnets         = values({for s, id in  module.main_vpc.subnet_ids  : s => id if length(regexall(".*-eks-.*", s)) > 0})
  version = "14.0.0"
  cluster_create_timeout = "1h"
  cluster_endpoint_private_access = true
  cluster_endpoint_private_access_cidrs  = ["0.0.0.0/0"]
  cluster_endpoint_public_access = true

  // Cluster logging
  cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  cluster_log_retention_in_days = 7

  tags = local.tags

  vpc_id = module.main_vpc.vpc_id

  worker_groups_launch_template = [

    {
      name                          = "spot-eks"
      override_instance_types       = ["t3.large"]
      root_volume_size              = "10"
      root_encrypted                = true
      ebs_optimized                 = false
      spot_instance_pools           = 2
      asg_max_size                  = 2
      asg_min_size                  = 2
      asg_desired_capacity          = 2
      kubelet_extra_args            = "--node-labels=node.kubernetes.io/lifecycle=spot"
      subnets                       = values({for s, id in module.main_vpc.subnet_ids : s => id if length(regexall(".*-eks-.*", s)) > 0})
      public_ip                     = false
      key_name                      = "test-eks"
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]
    }
  ]


  worker_additional_security_group_ids = [aws_security_group.all_worker_mgmt.id]
  map_roles                            = var.map_roles
  map_users                            = var.map_users
  map_accounts                         = var.map_accounts
}

resource "random_string" "suffix" {
  length  = 4
  special = false
}

resource "aws_security_group" "worker_group_mgmt_one" {
  name_prefix = "worker_group_mgmt_one"
  vpc_id      = module.main_vpc.vpc_id

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"

    cidr_blocks = values({for s, id in module.main_vpc.subnet_ipv4 : s => id
               if length(regexall(".*-eks-.*", s)) > 0})
  }
}

resource "aws_security_group" "all_worker_mgmt" {
  name_prefix = "all_worker_management"
  vpc_id      =  module.main_vpc.vpc_id
}

resource "aws_security_group_rule" "eks_cluster_add_access" {
  description = "Alow connections from some ip if needed =)"
  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = module.eks.cluster_security_group_id
}
