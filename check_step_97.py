import json
import io
import sys

sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

with open(r'C:\Users\pojot\.gemini\antigravity-ide\brain\bcfd0232-5db6-4097-8d92-1e946678df20\.system_generated\logs\transcript_full.jsonl', 'r', encoding='utf-8') as f:
    for line in f:
        try:
            step = json.loads(line)
            if step['step_index'] == 97:
                for tool in step['tool_calls']:
                    print("TOOL:", tool['name'])
                    print("FILE:", tool['args'].get('TargetFile'))
        except: pass
