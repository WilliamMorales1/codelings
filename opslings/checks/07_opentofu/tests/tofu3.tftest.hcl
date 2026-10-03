run "valid_defaults" {
  command = plan
}

run "valid_prod" {
  command = plan
  variables {
    environment = "prod"
    replicas    = 10
    cidr        = "192.168.0.0/24"
  }
}

run "bad_environment" {
  command = plan
  variables {
    environment = "qa"
  }
  expect_failures = [var.environment]
}

run "zero_replicas" {
  command = plan
  variables {
    replicas = 0
  }
  expect_failures = [var.replicas]
}

run "too_many_replicas" {
  command = plan
  variables {
    replicas = 11
  }
  expect_failures = [var.replicas]
}

run "fractional_replicas" {
  command = plan
  variables {
    replicas = 2.5
  }
  expect_failures = [var.replicas]
}

run "bad_cidr" {
  command = plan
  variables {
    cidr = "10.0.0.300/16"
  }
  expect_failures = [var.cidr]
}

run "not_a_cidr" {
  command = plan
  variables {
    cidr = "banana"
  }
  expect_failures = [var.cidr]
}
