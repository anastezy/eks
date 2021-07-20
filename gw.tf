module "main_igw" {
  source       = "git::git@gitlab.favorit:DevOps/terraform/modules.git//gw?ref=master"
  common_tags         = local.tags
  igw_vpc_id   = module.main_vpc.vpc_id
  igw_additional_tags = {
    Name = "${local.env}-${local.account}"
    }
  nat_gateways = {
    test-app-pub-1a = {
      subnet_id = module.main_vpc.subnet_ids[local.public_subnet1a]
    }
    test-app-pub-1b = {
      subnet_id = module.main_vpc.subnet_ids[local.public_subnet1b]
    }
  }
}
