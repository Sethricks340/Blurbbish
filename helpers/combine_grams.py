import json

files = [
    r"C:\Users\sethr\backup\Desktop\Blurbby\dicts\bi_dict_position.json",
    r"C:\Users\sethr\backup\Desktop\Blurbby\dicts\tri_dict_position.json",
    r"C:\Users\sethr\backup\Desktop\Blurbby\dicts\quad_dict_position.json",
    r"C:\Users\sethr\backup\Desktop\Blurbby\dicts\quint_dict_position.json"
]

combined = {}

for file in files:
    with open(file, "r", encoding="utf-8") as f:
        data = json.load(f)
        combined.update(data)

with open(r"C:\Users\sethr\backup\Desktop\Blurbby\dicts\grams.json", "w", encoding="utf-8") as f:
    json.dump(combined, f, indent=4)