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
    url = "http://127.0.0.1:13100/loki/api/v1/push"
  }
}
