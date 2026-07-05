import json

with open('models.json') as f:
    data = json.load(f)

models = []
for m in data['data']:
    model_id = m['id']
    name = m.get('name', model_id)
    owned_by = m.get('owned_by', 'unknown')
    ctx = m.get('context_length', 128000)
    max_out = m.get('max_output_tokens', 16000)
    caps = m.get('capabilities', {})
    
    models.append({
        "id": model_id,
        "name": f"{name} ({owned_by})",
        "url": "http://localhost:20128/v1/chat/completions",
        "toolCalling": caps.get('tool_calling', True),
        "vision": caps.get('vision', False),
        "maxInputTokens": ctx,
        "maxOutputTokens": max_out,
        "streaming": True
    })

# Sort: combos first, then by name
models.sort(key=lambda x: (not x['id'].startswith('auto'), x['id']))

print(json.dumps(models, indent=4))
print(f"\nTotal: {len(models)} models")