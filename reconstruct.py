import json
transcript = r'C:\Users\pojot\.gemini\antigravity-ide\brain\bcfd0232-5db6-4097-8d92-1e946678df20\.system_generated\logs\transcript_full.jsonl'
target = '2026-07-30T09:51:00Z'
file_path = r'c:\Users\pojot\StudioProjects\Pojo Infra360\lib\view\material_category\material_request\material_request_list_screen.dart'

content = ""

with open(transcript, 'r', encoding='utf-8') as f:
    for line in f:
        try:
            step = json.loads(line)
            time = step.get('created_at', '')
            if time < target and 'tool_calls' in step:
                for tool in step['tool_calls']:
                    args = tool.get('args', {})
                    if file_path.lower() in args.get('TargetFile', '').lower():
                        name = tool['name']
                        if name == 'write_to_file':
                            content = args.get('CodeContent', '')
                            print(f"Step {step['step_index']}: Wrote full file")
                        elif name == 'replace_file_content':
                            t = args.get('TargetContent', '')
                            r = args.get('ReplacementContent', '')
                            if t in content:
                                content = content.replace(t, r)
                                print(f"Step {step['step_index']}: Replaced")
                            else:
                                print(f"Step {step['step_index']}: FAILED TO FIND TARGET")
                        elif name == 'multi_replace_file_content':
                            for chunk in args.get('ReplacementChunks', []):
                                t = chunk.get('TargetContent', '')
                                r = chunk.get('ReplacementContent', '')
                                if t in content:
                                    content = content.replace(t, r)
                                    print(f"Step {step['step_index']}: Replaced chunk")
                                else:
                                    print(f"Step {step['step_index']}: FAILED TO FIND CHUNK TARGET")
        except: pass

with open(file_path, 'w', encoding='utf-8') as out:
    out.write(content)
print("Done reconstructing material_request_list_screen.dart")
