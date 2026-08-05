import json
transcript = r'C:\Users\pojot\.gemini\antigravity-ide\brain\bcfd0232-5db6-4097-8d92-1e946678df20\.system_generated\logs\transcript_full.jsonl'
target = '2026-07-30T09:51:00Z'
with open(transcript, 'r', encoding='utf-8') as f:
    for line in f:
        try:
            step = json.loads(line)
            if step['step_index'] in [87, 91, 167, 663]:
                print(f"\n--- STEP {step['step_index']} ---")
                for tool in step['tool_calls']:
                    args = tool.get('args', {})
                    file = args.get('TargetFile', '')
                    if 'api_data.dart' in file:
                        print("TOOL:", tool['name'])
                        print("TARGET:")
                        print(args.get('TargetContent', ''))
                        print("REPLACEMENT:")
                        print(args.get('ReplacementContent', ''))
        except: pass
