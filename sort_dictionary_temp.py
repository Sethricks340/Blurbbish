import json

path = r"C:\Users\sethr\backup\Desktop\Blurbby\Data\english_dictionary.json"

with open(path, "r", encoding="utf-8") as f:
    data = json.load(f)

sorted_data = dict(sorted(data.items()))

with open(path, "w", encoding="utf-8") as f:
    json.dump(sorted_data, f, indent=4, ensure_ascii=False)