# tofu4 -- count versus for_each
#
# Both create several instances of one resource:
#
#   count = 3            instances addressed by index:  x[0], x[1], x[2]
#   for_each = toset(l)  instances addressed by key:    x["logs"], ...
#
# With count, removing the first element of a list shifts every index, so
# OpenTofu destroys and recreates everything after it. for_each keys are
# stable. Rule of thumb: count for N identical copies, for_each for things
# with names.
#
#   tofu init && tofu plan
#   tofu plan -var 'buckets=["backups","assets"]'    # compare: what changes?
#
# Task:
#   - terraform_data.bucket: one instance per name in var.buckets, keyed by
#     that name, with input "${var.prefix}-${name}"
#   - terraform_data.worker: var.worker_count identical copies, input
#     "worker-<index>"
#   - output bucket_ids: map name => input, e.g. { logs = "acme-logs", ... }
#

variable "prefix" {
  type    = string
  default = "acme"
}

variable "buckets" {
  type    = list(string)
  default = ["logs", "backups", "assets"]
}

variable "worker_count" {
  type    = number
  default = 3
}

resource "terraform_data" "bucket" {
  for_each = toset(var.buckets)
  input    = "${var.prefix}-${each.key}"
}

resource "terraform_data" "worker" {
  count = var.worker_count
  input = "worker-${count.index}"
}

output "bucket_ids" {
  value = { for name, b in terraform_data.bucket : name => b.output }
}
