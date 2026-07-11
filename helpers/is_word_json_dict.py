import json


# Load dictionary once when program starts
with open(r"C:\Users\sethr\backup\Desktop\Blurbby\dicts\wordnet_definitions.json", "r", encoding="utf-8") as f:
    word_definitions = json.load(f)


print("\n")

word = input("Enter word: ").lower().strip()


if word in word_definitions:
    print("\n")
    print(f"{word}")
    print()

    for i, meaning in enumerate(word_definitions[word], 1):
        print(f"{i}. {meaning}")

    print("\n")

else:
    print("\n")
    print(f"'{word}' is not in WordNet.")
    print("\n")