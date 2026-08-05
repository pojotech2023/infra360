import json
import os

with open('edits_after_1521.json', 'r', encoding='utf-8') as f:
    edits = json.load(f)

edits = [e for e in edits if 'lib\\' in e['args'].get('TargetFile', '')]
edits.reverse()

for e in edits:
    target_file = e['args'].get('TargetFile')
    if not os.path.exists(target_file):
        print(f"Skipping {target_file}")
        continue
    
    with open(target_file, 'r', encoding='utf-8') as f:
        content = f.read()
        
    tool = e['tool']
    args = e['args']
    
    changed = False
    if tool == 'replace_file_content':
        target = args.get('TargetContent', '')
        replacement = args.get('ReplacementContent', '')
        
        if replacement in content:
            content = content.replace(replacement, target)
            changed = True
            print(f"Reverted step {e['step']} in {os.path.basename(target_file)}")
        else:
            # Maybe it was already reverted or modified manually
            print(f"FAILED to find ReplacementContent for step {e['step']} in {os.path.basename(target_file)}")
            
    elif tool == 'multi_replace_file_content':
        chunks = args.get('ReplacementChunks', [])
        for chunk in chunks:
            target = chunk.get('TargetContent', '')
            replacement = chunk.get('ReplacementContent', '')
            if replacement in content:
                content = content.replace(replacement, target)
                changed = True
                print(f"Reverted chunk of step {e['step']} in {os.path.basename(target_file)}")
            else:
                print(f"FAILED to find chunk for step {e['step']} in {os.path.basename(target_file)}")
                
    if changed:
        with open(target_file, 'w', encoding='utf-8') as f:
            f.write(content)
