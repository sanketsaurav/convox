terraform {
  required_version = ">= 0.12.0"
}

provider "digitalocean" {
  version = "~> 1.11"
}

provider "kubernetes" {
  version = "~> 1.10"
}

module "k8s" {
  source = "../k8s"

  providers = {
    kubernetes = kubernetes
  }

  domain  = module.router.endpoint
  name    = var.name
  release = var.release
}

module "api" {
  source = "../../api/do"

  providers = {
    digitalocean = digitalocean
    kubernetes   = kubernetes
  }

  access_id  = var.access_id
  domain     = module.router.endpoint
  name       = var.name
  namespace  = module.k8s.namespace
  region     = var.region
  release    = var.release
  resolver   = module.router.resolver
  router     = module.router.endpoint
  secret     = random_string.secret.result
  secret_key = var.secret_key
}

module "redis" {
  source = "../../redis/k8s"

  providers = {
    kubernetes = kubernetes
  }

  name      = "redis"
  namespace = module.k8s.namespace
}

module "router" {
  source = "../../router/do"

  providers = {
    digitalocean = digitalocean
    kubernetes   = kubernetes
  }

  name      = var.name
  namespace = module.k8s.namespace
  region    = var.region
  release   = var.release

  env = {
    CACHE      = "redis"
    REDIS_ADDR = module.redis.addr
  }
}
