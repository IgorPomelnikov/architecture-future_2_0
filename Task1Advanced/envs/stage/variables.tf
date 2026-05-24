variable "environment" {
  type = string
}

variable "nginx_image" {
  type    = string
  default = "nginx:latest"
}

variable "nginx_port" {
  type = number
}

variable "nginx_cpus" {
  type = number
}

variable "nginx_memory" {
  type = number
}
