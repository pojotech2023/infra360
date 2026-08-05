import json
import io
import sys

sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

with open(r'C:\Users\pojot\.gemini\antigravity-ide\brain\bcfd0232-5db6-4097-8d92-1e946678df20\.system_generated\logs\transcript_full.jsonl', 'r', encoding='utf-8') as f:
    for line in f:
        try:
            step = json.loads(line)
            if 'tool_calls' in step:
                for tool in step['tool_calls']:
                    args = tool.get('args', {})
                    if 'api_data.dart' in json.dumps(args):
                        print(f"Step {step.get('step_index')}: {tool['name']}")
            elif step.get('type') == 'ACTION_RESPONSE' or step.get('type') == 'CODE_ACTION':
                if 'api_data.dart' in step.get('content', ''):
                    print(f"Response at step {step.get('step_index')} contains api_data.dart. Length: {len(step.get('content', ''))}")
        except: pass
