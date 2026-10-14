import json
import os
import re

with open('scratch/all_materials_form_data.json', encoding='utf-8') as f:
    data = json.load(f)

for mat, info in data.items():
    print(f"\n==================== {mat.upper()} ====================")
    print("Labels:", info.get('labels'))
    print("Selects:")
    for s_name, opts in info.get('selects', {}).items():
        opt_texts = [o['text'] for o in opts]
        print(f"  [{s_name}]: {opt_texts}")
        
    # Also inspect HTML directly for inputs, datalists, autocomplete, or JS arrays
    html_file = f'scratch/{mat}_form.html'
    if os.path.exists(html_file):
        with open(html_file, encoding='utf-8') as hf:
            content = hf.read()
            
        # Look for JS scripts that might define suggestions
        scripts = re.findall(r'<script>(.*?)</script>', content, re.DOTALL)
        for s in scripts:
            # check any arrays or objects
            arrays = re.findall(r'(\w+)\s*=\s*(\[[^\]]+\])', s)
            for arr_name, arr_val in arrays:
                if len(arr_val) < 500:
                    print(f"  JS Array [{arr_name}]: {arr_val}")
                    
            # check autocomplete or datalists
            matches = re.findall(r'(\w+Options|\w+Data|\w+Suggestions|\w+Items)\s*=\s*({[^}]+})', s)
            for m_name, m_val in matches:
                print(f"  JS Object [{m_name}]: {m_val[:200]}")
