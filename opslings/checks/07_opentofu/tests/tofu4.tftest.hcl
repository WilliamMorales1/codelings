run "defaults" {
  command = apply

  assert {
    condition     = terraform_data.bucket["logs"].output == "acme-logs"
    error_message = "terraform_data.bucket[\"logs\"] should have input \"acme-logs\""
  }

  assert {
    condition     = length(terraform_data.bucket) == 3
    error_message = "expected 3 buckets"
  }

  assert {
    condition     = output.bucket_ids == { assets = "acme-assets", backups = "acme-backups", logs = "acme-logs" }
    error_message = "bucket_ids is wrong: ${jsonencode(output.bucket_ids)}"
  }

  assert {
    condition     = length(terraform_data.worker) == 3 && terraform_data.worker[2].output == "worker-2"
    error_message = "expected 3 workers, the last one worker-2"
  }
}

run "fewer" {
  command = apply

  variables {
    prefix       = "beta"
    buckets      = ["backups"]
    worker_count = 1
  }

  assert {
    condition     = keys(terraform_data.bucket) == ["backups"]
    error_message = "with buckets = [\"backups\"] there should be exactly bucket[\"backups\"]"
  }

  assert {
    condition     = output.bucket_ids == { backups = "beta-backups" }
    error_message = "bucket_ids is wrong: ${jsonencode(output.bucket_ids)}"
  }

  assert {
    condition     = length(terraform_data.worker) == 1
    error_message = "worker_count = 1 should give exactly one worker"
  }
}
