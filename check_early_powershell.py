import json
transcript = r'C:\Users\pojot\.gemini\antigravity-ide\brain\bcfd0232-5db6-4097-8d92-1e946678df20\.system_generated\logs\transcript_full.jsonl'
target = '2026-07-30T09:51:00Z'
with open(transcript, 'r', encoding='utf-8') as f:
    for line in f:
        try:
            step = json.loads(line)
            time = step.get('created_at', '')
            if time < target and 'tool_calls' in step:
                for tool in step['tool_calls']:
                    args = tool.get('args', {})
                    if tool['name'] == 'run_command' and ('powershell' in args.get('CommandLine','').lower() or 'set-content' in args.get('CommandLine','').lower()):
                        print(f"PowerShell at step {step['step_index']}: {args['CommandLine'][:100]}")
        except: pass
