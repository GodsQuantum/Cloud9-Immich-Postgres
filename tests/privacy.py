#!/usr/bin/env python3
from pathlib import Path
import subprocess,re,xml.etree.ElementTree as ET
base=Path(__file__).resolve().parents[1]
files=[f for f in subprocess.check_output(['git','-C',str(base),'ls-files','-z']).decode().split(chr(0)) if f]
blocked=[re.compile(x,re.I) for x in ('a'+'rezki','chou'+'gar','kech'+'idi','fe'+'lla',
 r'home[.]arpa',r'192[.]168[.]',r'/srv/lxc/',r'/home/'+'arezki',
 r'@gmail[.]com',r'@hotmail[.]com',r'github_pat_[a-z0-9_]{25,}',r'ghp_[a-z0-9]{25,}')]
bad=[]
for name in files:
 if name=='tests/privacy.py':continue
 f=base/name
 if f.is_file() and f.stat().st_size<500000 and any(q.search(f.read_text(errors='replace')) for q in blocked):bad.append(name)
assert not bad,bad
for name in ('Dockerfile','healthcheck.sh','immich-docker-entrypoint.sh','set-env.sh','postgresql.hdd.conf','postgresql.ssd.conf','README.md','README.fr.md','README.zh-CN.md','LICENSE'):assert (base/name).is_file()
for name in ('logo.svg','architecture.svg'):ET.parse(base/'docs'/name)
d=(base/'Dockerfile').read_text()
assert 'VECTORCHORD_VERSION=1.1.1' in d and 'postgres:18-bookworm' in d and 'pgvector/pgvector:0.8.5-pg18' in d
assert 'DB_STORAGE_TYPE' in (base/'immich-docker-entrypoint.sh').read_text()
assert 'IGNORE_DATABASE_FSTYPE' in (base/'immich-docker-entrypoint.sh').read_text()
print('IMMICH_POSTGRES_PUBLIC_PRIVACY_SSD_HDD_EXTENSION_BASELINE_PASS')
