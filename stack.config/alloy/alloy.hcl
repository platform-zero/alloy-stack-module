logging {
  level  = "info"
  format = "logfmt"
}

loki.source.journal "containers" {
  max_age    = "24h"
  forward_to = [loki.write.local.receiver]
  labels = {
    source = "journald",
    stack  = "webservices",
  }
}

loki.write "local" {
  endpoint {
    url = "http://loki:3100/loki/api/v1/push"
  }
}
