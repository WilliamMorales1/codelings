# A reusable "service" module: give it a name and a port, get an address.

variable "name" {
  type = string
}

variable "port" {
  type = number
}

variable "namespace" {
  type    = string
  default = "default"
}

resource "terraform_data" "service" {
  input = {
    name = var.name
    port = var.port
  }
}

output "address" {
  value = "${var.name}.${var.namespace}.svc.cluster.local:${var.port}"
}
