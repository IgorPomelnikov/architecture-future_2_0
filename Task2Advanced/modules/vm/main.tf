terraform {
  required_providers {
    docker = {
      source  = "registry.opentofu.org/kreuzwerker/docker"
      version = "4.4.0"
    }
  }
}

locals {
  name_prefix = var.environment
}

resource "docker_image" "nginx" {
  name         = var.nginx_image
  keep_locally = true
}

resource "docker_volume" "shared_volume" {
  name = "${local.name_prefix}-shared_volume"
}

resource "docker_network" "private_network" {
  name   = "${local.name_prefix}-network"
  driver = "bridge"
}

resource "docker_container" "nginx" {
  name  = "${local.name_prefix}-nginx"
  image = docker_image.nginx.image_id

  cpus   = var.nginx_cpus
  memory = var.nginx_memory

  volumes {
    volume_name    = docker_volume.shared_volume.name
    container_path = var.volume_mount_path
    read_only      = false
  }

  networks_advanced {
    name = docker_network.private_network.name
  }

  ports {
    external = var.nginx_port
    internal = 80
  }
}
