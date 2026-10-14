import requests, re

s = requests.Session()
r1 = s.get('http://pojoinfra360.pojotech.in/admin/login')
token = re.search(r'name=["\']_token["\']\s+value=["\']([^"\']+)["\']', r1.text).group(1)
s.post('http://pojoinfra360.pojotech.in/admin/login', data={'_token': token, 'mobile_no': '9999999999', 'password': 'Admin@123'})

candidates = [
    'http://pojoinfra360.pojotech.in/admin/material%20requestForm/51/sand',
    'http://pojoinfra360.pojotech.in/admin/material_requestForm/51/sand',
    'http://pojoinfra360.pojotech.in/admin/material-requestForm/51/sand',
    'http://pojoinfra360.pojotech.in/admin/material-request-form/51/sand',
    'http://pojoinfra360.pojotech.in/admin/material/request-form/51/sand',
    'http://pojoinfra360.pojotech.in/admin/material/requestForm/51/sand',
]
for c in candidates:
    res = s.get(c)
    print(c, '->', res.status_code)
