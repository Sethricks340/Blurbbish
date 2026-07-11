import json


with open(r"C:\Users\sethr\backup\Desktop\Blurbby\dicts\wordnet_definitions.json", "r", encoding="utf-8") as f:
    word_definitions = json.load(f)
with open(r"C:\Users\sethr\backup\Desktop\Blurbby\dicts\bi_dict.json", "r", encoding="utf-8") as f:
    bi_dict = json.load(f)
with open(r"C:\Users\sethr\backup\Desktop\Blurbby\dicts\tri_dict.json", "r", encoding="utf-8") as f:
    tri_dict = json.load(f)
with open(r"C:\Users\sethr\backup\Desktop\Blurbby\dicts\quad_dict.json", "r", encoding="utf-8") as f:
    quad_dict = json.load(f)
with open(r"C:\Users\sethr\backup\Desktop\Blurbby\dicts\quint_dict.json", "r", encoding="utf-8") as f:
    quint_dict = json.load(f)


print("\n")
for group in range(2, 6):

    if group == 2: dictionary = bi_dict
    elif group == 3: dictionary = tri_dict
    elif group == 4: dictionary = quad_dict
    elif group == 5: dictionary = quint_dict

    max_key = ""
    max_value = -1
    min_value = ""
    min_value = 99999
    for key, value in dictionary.items():
        if value <= min_value:
            min_value = value
            min_key = key
        if value >= max_value:
            max_value = value
            max_key = key
            
    print(f"{max_key}: {max_value}")
    print(f"{min_key}: {min_value}")
    # print("\n")







print("\n")