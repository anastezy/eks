terraform {
    required_version = ">= 0.12.31"

    required_providers {
      # aws        = ">= 3.19.0"
      local      = ">= 1.4"
      random     = ">= 2.1"
      null       = "~> 2.1"
      template   = "~> 2.1"
      # kubernetes = "~> 1.11"
    }
 //   backend "s3" {
 //       bucket               = "tf-state-testing-eu-central-1"
 //       key                  = "Testing/eks/terraform.tfstate"
 //       encrypt              = "true"
 //       region               = "eu-central-1"
 //       dynamodb_table       = "terraform-state-lock-dynamo"
 //   }
}

provider "aws" {
  region  = var.region
  version = ">= 3.19.0"
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
  version                = "~> 1.11"
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    exec {
      api_version = "client.authentication.k8s.io/v1alpha1"
      args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.cluster.name]
      command     = "aws"
    }
  }
}

data "aws_availability_zones" "available" {
}