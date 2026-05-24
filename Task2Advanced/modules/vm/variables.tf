variable "environment" {
  type        = string
  description = "Environment name (dev, stage, prod). Used as a prefix for resource names."

  validation {
    condition     = contains(["dev", "stage", "prod"], var.environment)
    error_message = "environment must be one of: dev, stage, prod."
  }
}

variable "nginx_image" {
  type        = string
  description = "Docker image for nginx."
  default     = "nginx:latest"
}

variable "nginx_port" {
  type        = number
  description = "Host port mapped to container port 80."
}

variable "nginx_cpus" {
  type        = number
  description = "CPU limit for the nginx container."
}

variable "nginx_memory" {
  type        = number
  description = "Memory limit for the nginx container (MB)."
}

variable "volume_mount_path" {
  type        = string
  description = "Path inside the container where the shared volume is mounted."
  default     = "/data"
}
