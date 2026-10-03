variables {
  app = "shop"
}

run "defaults" {
  command = plan

  assert {
    condition     = output.name == "shop-dev"
    error_message = "name should be \"shop-dev\", got ${jsonencode(output.name)}"
  }

  assert {
    condition     = output.url == "http://shop.dev.internal:8080"
    error_message = "url should be \"http://shop.dev.internal:8080\", got ${jsonencode(output.url)}"
  }
}

run "overrides" {
  command = plan

  variables {
    app  = "billing"
    env  = "prod"
    port = 443
  }

  assert {
    condition     = output.name == "billing-prod"
    error_message = "with app=billing env=prod, name should be \"billing-prod\""
  }

  assert {
    condition     = output.url == "http://billing.prod.internal:443"
    error_message = "with port=443, url should end in :443, got ${jsonencode(output.url)}"
  }
}
