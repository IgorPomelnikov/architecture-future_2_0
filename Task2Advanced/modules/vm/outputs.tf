output "container_name" {
  description = "Docker container name."
  value       = docker_container.nginx.name
}

output "container_id" {
  description = "Docker container ID."
  value       = docker_container.nginx.id
}

output "network_name" {
  description = "Docker network name."
  value       = docker_network.private_network.name
}

output "volume_name" {
  description = "Docker volume name."
  value       = docker_volume.shared_volume.name
}

output "nginx_url" {
  description = "URL to reach nginx on the host."
  value       = "http://localhost:${var.nginx_port}"
}

output "nginx_port" {
  description = "Published host port for nginx."
  value       = var.nginx_port
}
