output "environment" {
  value = var.environment
}

output "nginx_url" {
  value = module.vm.nginx_url
}

output "container_name" {
  value = module.vm.container_name
}

output "state_key" {
  description = "S3 object key for this environment state (for documentation)."
  value       = "task2advanced/dev/terraform.tfstate"
}
