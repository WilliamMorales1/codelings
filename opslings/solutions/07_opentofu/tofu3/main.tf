# tofu3 -- input validation
#
# A validation block rejects bad input at plan time, with your error
# message, instead of letting it fail halfway through an apply:
#
#   variable "x" {
#     validation {
#       condition     = <bool expression using var.x>
#       error_message = "Explain what is allowed."
#     }
#   }
#
# If the condition itself errors (a function that chokes on bad input),
# you get a raw error instead of your message. Wrap such calls in can(),
# which turns "error" into false.
#
#   tofu plan -var environment=qa        # should be refused, politely
#
# Task:
#   environment   one of "dev", "staging", "prod"
#   replicas      a whole number from 1 to 10
#   cidr          a valid IPv4 CIDR block such as "10.0.0.0/16"
# Invalid values must fail *validation* (the check uses expect_failures).
#

variable "environment" {
  type    = string
  default = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of dev, staging, prod."
  }
}

variable "replicas" {
  type    = number
  default = 2

  validation {
    condition     = var.replicas >= 1 && var.replicas <= 10 && floor(var.replicas) == var.replicas
    error_message = "replicas must be a whole number from 1 to 10."
  }
}

variable "cidr" {
  type    = string
  default = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.cidr, 0))
    error_message = "cidr must be a valid IPv4 CIDR block, like 10.0.0.0/16."
  }
}

resource "terraform_data" "network" {
  input = {
    environment = var.environment
    replicas    = var.replicas
    cidr        = var.cidr
  }
}
