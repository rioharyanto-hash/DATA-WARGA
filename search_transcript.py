import json

transcript_path = r'C:\Users\user\.gemini\antigravity-ide\brain\863c3a9b-3e69-4f4b-aa7a-5786ce56735d\.system_generated\logs\transcript_full.jsonl'
with open(transcript_path, 'r', encoding='utf-8') as f:
    for line in f:
        try:
            data = json.loads(line)
            if 'content' in data and 'generateYatimPiatuPdf' in data['content']:
                print(f"Found in step {data.get('step_index')}, type: {data.get('type')}")
                idx = data['content'].find('generateYatimPiatuPdf')
                # extract 2000 characters around it
                start = max(0, idx - 500)
                end = min(len(data['content']), idx + 10000)
                print(data['content'][start:end])
                print('---')
                break
        except Exception as e:
            pass
