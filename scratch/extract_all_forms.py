import requests, re, json

s = requests.Session()
r1 = s.get('http://pojoinfra360.pojotech.in/admin/login')
token = re.search(r'name=["\']_token["\']\s+value=["\']([^"\']+)["\']', r1.text).group(1)
s.post('http://pojoinfra360.pojotech.in/admin/login', data={'_token': token, 'mobile_no': '9999999999', 'password': 'Admin@123'})

# Try popular material keys
materials = [
    'bricks', 'sand', 'cement', 'steel', 'electricalwire', 
    'wood', 'plumbing', 'tiles', 'paint', 'doors_windows', 
    'aggregate', 'granite_marble', 'sanitaryware', 'hardware', 
    'glass', 'roofing', 'readymix_concrete', 'safety'
]

results = {}

for mat in materials:
    url = f'http://pojoinfra360.pojotech.in/admin/material-requestForm/51/{mat}'
    res = s.get(url)
    if res.status_code == 200:
        html = res.text
        with open(f'scratch/{mat}_form.html', 'w', encoding='utf-8') as f:
            f.write(html)
            
        # Parse fields
        mat_info = {
            'url': url,
            'labels': [],
            'fields': []
        }
        
        # Find all form groups
        # In Bootstrap / Admin panels, usually div class="form-group" or mb-3
        # Let's extract all labels and their corresponding input/select/textarea
        groups = re.findall(r'<div[^>]*class=["\'][^"\']*(?:form-group|mb-3|col-)[^"\']*["\'][^>]*>(.*?)</div>', html, re.DOTALL)
        
        # Or let's search for all labels
        labels = re.findall(r'<label[^>]*>(.*?)</label>', html, re.DOTALL)
        for l in labels:
            clean_l = re.sub(r'<[^>]+>', '', l).strip()
            if clean_l and clean_l not in mat_info['labels']:
                mat_info['labels'].append(clean_l)
                
        # Find selects
        selects = re.findall(r'<select[^>]*name=["\']([^"\']+)["\'][^>]*>(.*?)</select>', html, re.DOTALL)
        select_dict = {}
        for s_name, s_opts in selects:
            opts = re.findall(r'<option[^>]*value=["\']([^"\']*)["\'][^>]*>(.*?)</option>', s_opts, re.DOTALL)
            clean_opts = [{'value': o[0], 'text': re.sub(r'<[^>]+>', '', o[1]).strip()} for o in opts if re.sub(r'<[^>]+>', '', o[1]).strip()]
            select_dict[s_name] = clean_opts
        mat_info['selects'] = select_dict
        
        # Find input suggestions / dropdowns (often in script or datalist or autocomplete)
        scripts = re.findall(r'<script[^>]*>(.*?)</script>', html, re.DOTALL)
        suggestions = {}
        for sc in scripts:
            for m in re.finditer(r'var\s+(\w+)\s*=\s*(\[[^\]]+\])', sc):
                suggestions[m.group(1)] = m.group(2)[:300]
            for m in re.finditer(r'source\s*:\s*(\[[^\]]+\])', sc):
                suggestions['source'] = m.group(1)[:300]
            # Check autocomplete or dropdown arrays
            for m in re.finditer(r'(\w+Suggestions|\w+List|\w+Options|\w+Data)\s*=\s*(\[[^\]]+\])', sc):
                suggestions[m.group(1)] = m.group(2)[:300]
        mat_info['suggestions'] = suggestions
        
        results[mat] = mat_info
        print(f"SUCCESS: {mat}")
    else:
        print(f"FAIL ({res.status_code}): {mat}")

with open('scratch/all_materials_form_data.json', 'w', encoding='utf-8') as f:
    json.dump(results, f, indent=2)

print("Saved to scratch/all_materials_form_data.json")
