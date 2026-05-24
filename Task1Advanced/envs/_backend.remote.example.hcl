# Example remote backend for team/CI (copy into envs/<env>/backend.tf and adjust).
#
# terraform {
#   backend "s3" {
#     bucket         = "my-terraform-state"
#     key            = "task1advanced/envs/dev/terraform.tfstate"
#     region         = "eu-central-1"
#     encrypt        = true
#     dynamodb_table = "terraform-locks"
#   }
# }
