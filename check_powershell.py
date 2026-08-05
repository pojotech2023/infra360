import json
with open('edits_after_1521.json', 'r', encoding='utf-8') as f:
    edits = json.load(f)
for e in edits:
    if 'powershell' in e.get('args', {}).get('CommandLine', '').lower() or 'set-content' in e.get('args', {}).get('CommandLine', '').lower():
        print(f"PowerShell run at step {e['step']}: {e['args']['CommandLine'][:200]}")
