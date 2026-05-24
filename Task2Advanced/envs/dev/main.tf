terraform {
  required_version = ">= 1.5.0"

  required_providers {
    docker = {
      source  = "registry.opentofu.org/kreuzwerker/docker"
      version = "4.4.0"
    }
  }

  # Remote state: credentials and endpoint via backend.hcl (not in git).
  backend "s3" {}
}

provider "docker" {}

module "vm" {
  source = "../../modules/vm"

  environment  = var.environment
  nginx_image  = var.nginx_image
  nginx_port   = var.nginx_port
  nginx_cpus   = var.nginx_cpus
  nginx_memory = var.nginx_memory
}
