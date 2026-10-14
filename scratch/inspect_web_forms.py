import requests
import re
import json

s = requests.Session()
r1 = s.get('http://pojoinfra360.pojotech.in/admin/login')
m = re.search(r'name=["\']_token["\']\s+value=["\']([^"\']+)["\']', r1.text)
token = m.group(1) if m else None

r2 = s.post('http://pojoinfra360.pojotech.in/admin/login', data={
    '_token': token,
    'mobile_no': '9999999999',
    'password': 'Admin@123'
})
print('Login status:', r2.status_code)

materials = ['bricks', 'sand', 'cement', 'steel', 'electricalwire', 'wood', 'plumbing', 'tiles', 'paint', 'doors_windows', 'aggregate', 'granite_marble']

results = {}

for mat in materials:
    url = f'http://pojoinfra360.pojotech.in/admin/material/requestForm/51/{mat}'
    res = s.get(url)
    if res.status_code != 200:
        continue
    
    html = res.text
    # Save first html to see structure
    if mat == 'sand':
        with open('scratch/sand_form.html', 'w', encoding='utf-8') as f:
            f.write(html)
            
    mat_data = {
        'labels': [],
        'selects': {},
        'datalists': {},
        'js_suggestions': {}
    }
    
    # Extract labels
    labels = re.findall(r'<label[^>]*>(.*?)</label>', html, re.DOTALL)
    mat_data['labels'] = [re.sub(r'<[^>]+>', '', l).strip() for l in labels if l.strip()]
    
    # Extract selects
    selects = re.findall(r'<select[^>]*name=["\']([^"\']+)["\'][^>]*>(.*?)</select>', html, re.DOTALL)
    for s_name, s_opts in selects:
        opts = re.findall(r'<option[^>]*value=["\']([^"\']*)["\'][^>]*>(.*?)</option>', s_opts, re.DOTALL)
        mat_data['selects'][s_name] = [
            {'val': o[0], 'text': re.sub(r'<[^>]+>', '', o[1]).strip()}
            for o in opts if o[1].strip()
        ]
        
    # Extract datalists
    datalists = re.findall(r'<datalist[^>]*id=["\']([^"\']+)["\'][^>]*>(.*?)</datalist>', html, re.DOTALL)
    for dl_id, dl_opts in datalists:
        opts = re.findall(r'<option[^>]*value=["\']([^"\']*)["\']', dl_opts)
        mat_data['datalists'][dl_id] = opts

    # Check for javascript arrays / suggestion scripts
    js_blocks = re.findall(r'<script[^>]*>(.*?)</script>', html, re.DOTALL)
    for jb in js_blocks:
        # Look for arrays like var suggestions = [...] or similar
        arrs = re.findall(r'(\w+)\s*=\s*(\[[^\]]+\])', jb)
        for var_name, arr_val in arrs:
            try:
                mat_data['js_suggestions'][var_name] = json.loads(arr_val.replace("'", '"'))
            except:
                mat_data['js_suggestions'][var_name] = arr_val[:200]
                
    results[mat] = mat_data

with open('scratch/all_forms_analysis.json', 'w', encoding='utf-8') as f:
    json.dump(results, f, indent=2)

print('Forms inspected:', list(results.keys()))
