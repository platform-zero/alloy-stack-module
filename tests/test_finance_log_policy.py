#!/usr/bin/env python3
"""SOURCE ONLY: metadata/regex assertions, NOT journal/data-flow acceptance."""
import re
from pathlib import Path
root=Path(__file__).resolve().parents[1];text=(root/'stack.config/alloy/alloy.hcl').read_text()
assert 'relabel_rules = loki.relabel.human_finance_private.rules' in text
for label in ['__journal_container_name','__journal__systemd_user_unit','__journal__systemd_unit']:
 assert 'source_labels = ["'+label+'"]' in text
assert text.count('action        = "drop"')==3
for name in ['firefly','firefly-identity-check','firefly-sso','firefly-native-api','firefly-cron','firefly-importer','firefly-importer-sso']:
 assert re.fullmatch('.*firefly.*',name)
assert 'forward_to = [loki.process.human_finance_private.receiver]' in text
assert 'expression = "(?i)firefly"' in text
for message in ['PUBLIC host=firefly.source.invalid URI_MARKER','PUBLIC from=<firefly@example.invalid>','PUBLIC FIREfly-importer.source.invalid']:
 assert re.search('(?i)firefly',message)
assert not re.search('(?i)firefly','PUBLIC unrelated keycloak health metadata')
print('SOURCE ONLY: private financial journal-label and shared-host marker filter assertions passed; native/installed data-flow proof separate')
