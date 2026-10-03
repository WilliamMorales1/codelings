# tofu2 -- locals and for expressions
#
# `locals` name intermediate values so you compute them once. `for`
# expressions transform collections, much like list comprehensions:
#
#   [for x in list : f(x)]                 -> list
#   [for k, v in map : k if v.enabled]     -> list, filtered
#   {for k, v in map : k => f(v)}          -> map
#
# Iterating a map yields keys in sorted order.
#
#   tofu init && tofu console
#   > local.public_services
#
# Task, from var.services:
#   local.public_services  sorted list of the *names* of public services
#                          -> ["api", "web"]
#   local.endpoints        map name => "<name>.internal:<port>"
#                          -> { api = "api.internal:8080", ... }
#   local.total_ports      sum of all ports (hint: sum([...]))
# The outputs expose them; the check also tries other inputs.
#

variable "services" {
  type = map(object({
    port   = number
    public = bool
  }))
  default = {
    web    = { port = 80, public = true }
    api    = { port = 8080, public = true }
    worker = { port = 9000, public = false }
  }
}

locals {
  public_services = [for s in var.services : s if s.public]
  endpoints       = { for name, s in var.services : name => "${name}:${s.port}" }
  total_ports     = 0 # TODO
}

output "public_services" {
  value = local.public_services
}

output "endpoints" {
  value = local.endpoints
}

output "total_ports" {
  value = local.total_ports
}
