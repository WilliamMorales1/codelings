run "defaults" {
  command = plan

  assert {
    condition     = output.public_services == ["api", "web"]
    error_message = "public_services should be [\"api\", \"web\"], got ${jsonencode(output.public_services)}"
  }

  assert {
    condition = output.endpoints == {
      api    = "api.internal:8080"
      web    = "web.internal:80"
      worker = "worker.internal:9000"
    }
    error_message = "endpoints are wrong: ${jsonencode(output.endpoints)}"
  }

  assert {
    condition     = output.total_ports == 17160
    error_message = "total_ports should be 17160, got ${jsonencode(output.total_ports)}"
  }
}

run "other_services" {
  command = plan

  variables {
    services = {
      db    = { port = 5432, public = false }
      front = { port = 443, public = true }
    }
  }

  assert {
    condition     = output.public_services == ["front"]
    error_message = "with only `front` public, public_services should be [\"front\"], got ${jsonencode(output.public_services)}"
  }

  assert {
    condition     = output.endpoints == { db = "db.internal:5432", front = "front.internal:443" }
    error_message = "endpoints are wrong for other input: ${jsonencode(output.endpoints)}"
  }

  assert {
    condition     = output.total_ports == 5875
    error_message = "total_ports should be 5875 for other input, got ${jsonencode(output.total_ports)}"
  }
}
