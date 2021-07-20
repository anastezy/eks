module "main_vpc" {
  source                   = "git::git@gitlab.favorit:DevOps/terraform/modules.git//networking?ref=master"
  common_tags              = local.tags
  vpc_network_cidr         = "10.100.0.0/16"
  main_route_table         = "public-rt"
  vpc_additional_tags      = {
    Name = "${local.env}-${local.account}"
    }
  subnets = {
    "test-app-pub-1a" = {
      cidr            = "10.100.110.0/24",
      az              = "eu-central-1a",
      additional_tags = {}
      route_table = "public-rt"
    },
    "test-app-pub-1b" = {
      cidr            = "10.100.111.0/24",
      az              = "eu-central-1b",
      additional_tags = {}
      route_table = "public-rt"
    },
    "test-eks-1a" = {
      cidr            = "10.100.115.0/24",
      az              = "eu-central-1a",
      additional_tags = {"kubernetes.io/cluster/test-eks" = "shared"}
      route_table = "private-rt-1a"
    },
    "test-eks-1b" = {
      cidr            = "10.100.116.0/24",
      az              = "eu-central-1b",
      additional_tags = {"kubernetes.io/cluster/test-eks" = "shared"}
      route_table = "private-rt-1b"
    },
    "test-eks-1c" = {
      cidr            = "10.100.117.0/24",
      az              = "eu-central-1c",
      additional_tags = {"kubernetes.io/cluster/test-eks" = "shared"}
      route_table = "private-rt-1a"
    },
  }
 route_tables = {
    "public-rt" = {
      "0.0.0.0/0"         = {"gateway_id"    = module.main_igw.igw_id}
     }
   "private-rt-1a" = {
      "0.0.0.0/0"        = {"nat_gateway_id" = module.main_igw.nat_gw_ids[local.public_subnet1a]}
     }
   "private-rt-1b" = {
     "0.0.0.0/0"        = {"nat_gateway_id" = module.main_igw.nat_gw_ids[local.public_subnet1b]}
   }
 }
}
