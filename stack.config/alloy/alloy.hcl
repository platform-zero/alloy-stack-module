logging {
  level  = "info"
  format = "logfmt"
}

// Financial logs stay in the owner-controlled local journal, never general Loki.
// Shared main PostgreSQL errors can contain rejected financial values WITHOUT
// the database name. Keep its ENTIRE journal private, not just marked messages.
// Database liveness/aggregate metrics remain separate; SSD/exporter logs are not
// silently removed. Internal labels must be filtered before they are discarded.
loki.relabel "human_finance_private" {
  forward_to = []
  rule {
    source_labels = ["__journal_container_name"]
    regex         = ".*firefly.*|(^|.*[-_/])postgres([.]service|[.]container)?$"
    action        = "drop"
  }
  rule {
    source_labels = ["__journal__systemd_user_unit"]
    regex         = ".*firefly.*|(^|.*[-_/])postgres([.]service|[.]container)?$"
    action        = "drop"
  }
  rule {
    source_labels = ["__journal__systemd_unit"]
    regex         = ".*firefly.*|(^|.*[-_/])postgres([.]service|[.]container)?$"
    action        = "drop"
  }
}

loki.source.journal "containers" {
  max_age    = "24h"
  relabel_rules = loki.relabel.human_finance_private.rules
  forward_to = [loki.process.human_finance_private.receiver]
  labels = {
    source = "journald",
    stack  = "webservices",
  }
}

// Shared ingress/SMTP errors can mention a financial host even when emitted by
// another service. Drop those lines before the general log store as well.
loki.process "human_finance_private" {
  forward_to = [loki.write.local.receiver]
  stage.drop {
    expression = "(?i)firefly"
    drop_counter_reason = "human_finance_private"
  }
}

loki.write "local" {
  endpoint {
    url = "http://127.0.0.1:13100/loki/api/v1/push"
  }
}
