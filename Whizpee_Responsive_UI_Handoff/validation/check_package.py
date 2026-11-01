"""Package contract checks. Does not substitute for browser layout QA."""
from pathlib import Path
from html.parser import HTMLParser
import csv, hashlib, json, re, subprocess, tempfile
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT
INVENTORY = json.loads((ROOT / 'inventory.json').read_text())
results = []

def check(name, run):
    try:
        detail = run()
        results.append({'name': name, 'pass': True, 'detail': detail})
    except Exception as exc:
        results.append({'name': name, 'pass': False, 'detail': str(exc)})

class Document(HTMLParser):
    def __init__(self, source):
        super().__init__(); self.resources = []; self.scripts = []; self.inline = []; self._script = None
        self.feed(source)
    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        if tag in ['img', 'script', 'video', 'audio', 'source'] and attrs.get('src'):
            self.resources.append(attrs['src'])
        if tag == 'link' and attrs.get('rel') in ['stylesheet', 'preload', 'icon'] and attrs.get('href'):
            self.resources.append(attrs['href'])
        if tag == 'script':
            self._script = {'attrs': attrs, 'text': ''}; self.scripts.append(self._script)
    def handle_endtag(self, tag):
        if tag == 'script': self._script = None
    def handle_data(self, data):
        if self._script is not None: self._script['text'] += data

def html_contract(filename):
    p = OUT / filename
    source = p.read_text(); doc = Document(source)
    failures = []
    for value in doc.resources:
        if value.startswith(('http:', 'https:', '//')): failures.append('external resource '+value)
        elif not value.startswith(('data:', 'blob:', '#')):
            target = p.parent / value.split('?')[0].split('#')[0]
            if not target.exists(): failures.append('missing resource '+value)
    for url in re.findall(r'url\(\s*[\'\"]?([^\)\'\"]+)', source):
        if url.startswith(('http:', 'https:', '//')): failures.append('external CSS resource '+url)
    javascript = []
    for script in doc.scripts:
        attrs, text = script['attrs'], script['text']
        if attrs.get('type') == 'application/json':
            json.loads(text)
        elif not attrs.get('src'):
            javascript.append(text)
    for idx, script in enumerate(javascript):
        with tempfile.NamedTemporaryFile('w', suffix='.js') as f:
            f.write(script); f.flush()
            result = subprocess.run(['node', '--check', f.name], capture_output=True, text=True)
            if result.returncode: failures.append(f'inline JavaScript {idx}: '+result.stderr)
    combined = '\n'.join(javascript)
    prohibited = [r'localStorage\s*\.', r'sessionStorage\s*\.', r'indexedDB\s*\.',
                  r'\bfetch\s*\(', r'new\s+(?:WebSocket|XMLHttpRequest|EventSource)\s*\(']
    for pattern in prohibited:
        if re.search(pattern, combined): failures.append('network/persistence call '+pattern)
    assert not failures, '; '.join(failures)
    return {'bytes': p.stat().st_size, 'inlineScriptsSyntaxChecked': len(javascript), 'embeddedJson': len(doc.scripts)-len(javascript)}

def spec_coverage():
    names = list((OUT/'screen_specs').glob('*.md'))
    ids = [re.match(r'^([PSD]\d{2})', p.name).group(1) for p in names if re.match(r'^([PSD]\d{2})', p.name)]
    expected = {r['id'] for r in INVENTORY['rows']}
    assert set(ids) == expected, f'missing {sorted(expected-set(ids))}; extra {sorted(set(ids)-expected)}'
    assert len(ids) == len(expected), 'duplicate surface spec IDs'
    too_short = [p.name for p in names if len(p.read_text()) < 1200]
    assert not too_short, 'underspecified files '+str(too_short)
    return {'surfaceSpecifications': len(ids)}

def csv_coverage(name, expected, key='id'):
    with (OUT/name).open(newline='') as f: rows=list(csv.DictReader(f))
    assert rows, name+' empty'
    candidates = [key,'ID','surface_id','scenario_id','Surface ID','Scenario ID']
    actual_key = next((k for k in candidates if k in rows[0]), None)
    assert actual_key, 'unknown ID column '+str(rows[0].keys())
    ids = [r[actual_key] for r in rows]
    assert set(ids)==set(expected), f'{name} missing {set(expected)-set(ids)} extra {set(ids)-set(expected)}'
    assert len(ids)==len(expected), name+' duplicate IDs'
    return {'rows':len(rows),'columns':list(rows[0])}

def assets_contract():
    bad = []
    svgs = list((OUT/'assets').rglob('*.svg'))
    for p in svgs:
        try: ET.parse(p)
        except Exception as e: bad.append(str(p.relative_to(OUT))+': '+str(e))
    manifest = json.loads((OUT/'assets/manifest.json').read_text())
    for item in manifest['files']:
        p=OUT/item['path']
        if not p.exists(): bad.append('missing manifest file '+item['path']); continue
        if hashlib.sha256(p.read_bytes()).hexdigest()!=item['sha256']: bad.append('hash mismatch '+item['path'])
    assert not bad, '; '.join(bad)
    for font in ['Roboto-Regular.ttf','Roboto-Medium.ttf','Roboto-Bold.ttf']:
        assert (OUT/'assets/fonts'/font).stat().st_size>10000, font+' missing or empty'
    assert (OUT/'assets/brand/Whizpee-logo.png').exists(), 'logo absent'
    return {'validSvgAssets':len(svgs),'manifestFiles':len(manifest['files'])}

def token_contract():
    t=json.loads((OUT/'design_tokens.json').read_text())
    assert t['size']['railWidth']==76 and t['size']['listPaneWidth']==336 and t['size']['contextPaneWidth']==320
    assert t['layout']['breakpoints']['medium']['min']==600 and t['layout']['breakpoints']['expanded']['min']==1024 and t['layout']['breakpoints']['wide']['min']==1440
    assert t['size']['iconTouchTarget']>=44 and t['size']['fieldHeight']==48
    assert t['webCapabilities']['calls'] is False and t['webCapabilities']['videoCompression'] is False
    c=json.loads((OUT/'component_specs.json').read_text())
    return {'rail':76,'list':336,'context':320,'componentSpecTopLevelKeys':list(c)}

check('Prototype: offline resources, no network/persistence, valid embedded JSON and JavaScript', lambda:html_contract('Whizpee_Responsive_Prototype.html'))
check('Design system: offline resources, no network/persistence, valid embedded JSON and JavaScript', lambda:html_contract('Whizpee_Design_System.html'))
check('Handoff viewer: offline resources and valid JavaScript', lambda:html_contract('index.html'))
check('124 per-surface specifications', spec_coverage)
check('Surface coverage matrix', lambda:csv_coverage('coverage_matrix.csv',[r['id'] for r in INVENTORY['rows']]))
check('130 scenario matrix', lambda:csv_coverage('scenario_matrix.csv',[r['id'] for r in INVENTORY['states']]))
check('Valid assets and checksums',assets_contract)
check('Core responsive tokens and capability contract',token_contract)
print(json.dumps({'kind':'static-package-checks','tests':results},indent=2))
raise SystemExit(1 if any(not r['pass'] for r in results) else 0)
