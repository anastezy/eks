locals {
  env = "test"
  public_subnet1a= "test-app-pub-1a"
  public_subnet1b= "test-app-pub-1b"
  account = "Testing"
  tags = {
    env       = local.env
    account   = local.account
    ManagedBy = "Terraform"
  }
  common_tags = {
    env       = local.env
    account   = local.account
    ManagedBy = "Terraform"
  }
}
