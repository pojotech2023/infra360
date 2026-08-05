# coding=utf-8
import json
import io
import sys

sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

with open(r'C:\Users\pojot\.gemini\antigravity-ide\brain\bcfd0232-5db6-4097-8d92-1e946678df20\.system_generated\logs\transcript_full.jsonl', 'r', encoding='utf-8') as f:
    for line in f:
        if 'MultipartFile' in line and 'addWagesApi' in line:
            try:
                step = json.loads(line)
                print("FOUND IN STEP", step['step_index'])
                for tool in step['tool_calls']:
                    print(tool['args'].get('CodeContent', ''))
                    for c in tool['args'].get('ReplacementChunks', []):
                        print(c.get('ReplacementContent'))
            except: pass
