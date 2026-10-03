#!/usr/bin/env bash
# REQUIRES: tofu
# HINT
#   resource "terraform_data" "bucket" {
#     for_each = toset(var.buckets)
#     input    = "${var.prefix}-${each.key}"
#   }
#   resource "terraform_data" "worker" { count = var.worker_count ... }
#   output "bucket_ids" {
#     value = { for name, b in terraform_data.bucket : name => b.output }
#   }
source "$OPSLINGS_ROOT/checks/lib.sh"

need_file main.tf
tofu_test tofu4
