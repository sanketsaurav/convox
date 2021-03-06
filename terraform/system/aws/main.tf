terraform {
  required_version = ">= 0.12.0"
}

provider "aws" {
  version = "~> 2.22"
}

provider "http" {
  version = "~> 1.1"
}

provider "kubernetes" {
  version = "~> 1.10"

  cluster_ca_certificate = module.cluster.ca
  host                   = module.cluster.endpoint
  token                  = data.aws_eks_cluster_auth.cluster.token

  load_config_file = false
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.cluster.id
}

data "http" "releases" {
  url = "https://api.github.com/repos/convox/convox/releases"
}

locals {
  current = jsondecode(data.http.releases.body).0.tag_name
  release = coalesce(var.release, local.current)
}

module "cluster" {
  source = "../../cluster/aws"

  providers = {
    aws = aws
  }

  cidr      = var.cidr
  name      = var.name
  node_type = var.node_type
}

module "fluentd" {
  source = "../../fluentd/aws"

  providers = {
    aws        = aws
    kubernetes = kubernetes
  }

  cluster   = module.cluster.id
  namespace = "kube-system"
  name      = var.name
  oidc_arn  = module.cluster.oidc_arn
  oidc_sub  = module.cluster.oidc_sub
}

module "rack" {
  source = "../../rack/aws"

  providers = {
    aws        = aws
    kubernetes = kubernetes
  }

  cluster  = module.cluster.id
  name     = var.name
  oidc_arn = module.cluster.oidc_arn
  oidc_sub = module.cluster.oidc_sub
  release  = local.release
}
