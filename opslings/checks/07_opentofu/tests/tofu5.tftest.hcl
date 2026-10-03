run "addresses" {
  command = apply

  assert {
    condition     = output.api_address == "api.shop.svc.cluster.local:8080"
    error_message = "api_address should be api.shop.svc.cluster.local:8080, got ${jsonencode(output.api_address)}"
  }

  assert {
    condition     = output.web_address == "web.shop.svc.cluster.local:80"
    error_message = "web_address should be web.shop.svc.cluster.local:80, got ${jsonencode(output.web_address)}"
  }

  assert {
    condition     = module.web.address != module.api.address
    error_message = "the two modules should produce different addresses"
  }
}
