import json
import io
import sys

sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

failed_steps = [1145, 1625]

with open('edits_after_1521.json', 'r', encoding='utf-8') as f:
    edits = json.load(f)

for e in edits:
    if e['step'] in failed_steps:
        print(f"\n--- Step {e['step']} in {e['args'].get('TargetFile')} ---")
        if e['tool'] == 'replace_file_content':
            print("TARGET:")
            print(e['args'].get('TargetContent'))
            print("REPLACEMENT:")
            print(e['args'].get('ReplacementContent'))
