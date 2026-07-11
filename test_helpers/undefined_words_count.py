import json

with open(r"C:\Users\sethr\backup\Desktop\Blurbby\Data\english_dictionary.json", "r", encoding="utf-8") as f:
    word_definitions = json.load(f)

undefined_words = []
count = 0
for word in word_definitions:
    for i, meaning in enumerate(word_definitions[word], 1):
        if not meaning:
            count += 1
            undefined_words.append(word)

print(f"Number of undefined words: {count}")
input("Press enter to see undefined words. ")
print(undefined_words)