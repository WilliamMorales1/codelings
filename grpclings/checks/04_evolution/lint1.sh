#!/usr/bin/env bash
# REQUIRES: jq
# HINT
# `package acme.billing.v1;` fixes both package complaints (the file already
# sits in acme/billing/v1/). Enum values become INVOICE_STATUS_UNSPECIFIED,
# INVOICE_STATUS_DRAFT, INVOICE_STATUS_PAID; line_item becomes LineItem (update
# the field that uses it); invoiceId and customerID become invoice_id and
# customer_id.
source "$GRPCLINGS_LIB"
need_file buf.yaml
expect_buf_lint
buf_image
inv=$(msg_json acme.billing.v1.Invoice)
[[ -n "$inv" ]] || fail "no message acme.billing.v1.Invoice"
expect_eq "$(jq -r '[.field[] | "\(.name)=\(.number)"] | join(" ")' <<<"$inv")" "invoice_id=1 customer_id=2 lines=3 status=4" "Invoice fields"
expect_eq "$(jq -r '.field[] | select(.name == "lines") | .typeName' <<<"$inv")" ".acme.billing.v1.LineItem" "Invoice.lines holds LineItem"
li=$(msg_json acme.billing.v1.LineItem)
expect_eq "$(jq -r '[.field[] | "\(.name)=\(.number)"] | join(" ")' <<<"$li")" "sku=1 quantity=2" "LineItem fields"
expect_eq "$(img '[.file[].enumType[]? | select(.name == "InvoiceStatus") | .value[] | "\(.name)=\(.number)"] | join(" ")')" \
  "INVOICE_STATUS_UNSPECIFIED=0 INVOICE_STATUS_DRAFT=1 INVOICE_STATUS_PAID=2" "InvoiceStatus values"
