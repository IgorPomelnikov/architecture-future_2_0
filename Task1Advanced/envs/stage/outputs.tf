output "environment" {
  value = var.environment
}

output "nginx_url" {
  value = module.vm.nginx_url
}

output "container_name" {
  value = module.vm.container_name
}
