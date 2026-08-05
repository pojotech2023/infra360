import json
import sys

transcript_path = r'C:\Users\pojot\.gemini\antigravity-ide\brain\bcfd0232-5db6-4097-8d92-1e946678df20\.system_generated\logs\transcript_full.jsonl'
target_time = '2026-07-30T09:51:00Z'

edits = []

with open(transcript_path, 'r', encoding='utf-8') as f:
    for line in f:
        try:
            step = json.loads(line)
            if step.get('created_at', '') > target_time and 'tool_calls' in step:
                for tool in step['tool_calls']:
                    name = tool.get('name')
                    if name in ['replace_file_content', 'multi_replace_file_content', 'write_to_file']:
                        edits.append({
                            'step': step.get('step_index'),
                            'time': step.get('created_at'),
                            'tool': name,
                            'args': tool.get('args')
                        })
        except:
            pass

with open('edits_after_1521.json', 'w', encoding='utf-8') as out:
    json.dump(edits, out, indent=2)
