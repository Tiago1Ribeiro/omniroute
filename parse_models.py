import json

with open('models.json') as f:
    data = json.load(f)

print(f'Total models: {len(data["data"])}')
providers = {}
for m in data['data']:
    p = m.get('owned_by', 'unknown')
    providers[p] = providers.get(p, 0) + 1

for p, count in sorted(providers.items()):
    print(f'{p}: {count} models')

print()
print('Sample models:')
for m in data['data'][:15]:
    print(f'  - {m["id"]} ({m.get("owned_by", "unknown")})')