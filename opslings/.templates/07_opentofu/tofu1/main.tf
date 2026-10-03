# tofu1 -- variables, outputs and string templates
#
# OpenTofu (the open-source Terraform fork, written in Go) describes
# infrastructure in HCL. A module takes input *variables*, and exposes
# *outputs*. Inside a string, "${...}" interpolates an expression; a bare
# `var.x` inside quotes is just text.
#
# No cloud needed: this course only uses the built-in `terraform_data`
# resource, so `tofu init` downloads nothing.
#
#   tofu init
#   tofu plan -var app=shop
#   tofu apply -auto-approve -var app=shop && tofu output
#   rm -rf .terraform* terraform.tfstate*        # clean up afterwards
#
# Task, for app=shop, env=dev (the default), port=8080 (the default):
#   output name = "shop-dev"
#   output url  = "http://shop.dev.internal:8080"
# and port must be a number.
#

variable "app" {
  type        = string
  description = "Application name"
}

variable "env" {
  type    = string
  default = "dev"
}

variable "port" {
  type    = string
  default = "8080"
}

output "name" {
  value = "var.app-var.env"
}

output "url" {
  value = "http://${var.app}.${env}.internal:${var.port}"
}
