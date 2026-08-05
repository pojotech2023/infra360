import json
import os

transcript = r'C:\Users\pojot\.gemini\antigravity-ide\brain\bcfd0232-5db6-4097-8d92-1e946678df20\.system_generated\logs\transcript_full.jsonl'

with open(transcript, 'r', encoding='utf-8') as f:
    for line in f:
        try:
            step = json.loads(line)
            if step['step_index'] == 97:
                for tool in step['tool_calls']:
                    args = tool.get('args', {})
                    file = args.get('TargetFile', '')
                    if 'add_material_type_dialog.dart' in file:
                        content = args.get('CodeContent', '')
                        with open(file, 'w', encoding='utf-8') as out:
                            out.write(content)
                        print(f"Restored {file} from step 97")
        except: pass
