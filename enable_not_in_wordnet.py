import mmap

wordnet_words = set()

def load_wordnet_words(data_type):
    file_path = fr"C:\Users\sethr\backup\Desktop\Blurbby\wn3.1.dict\dict\index.{data_type}"

    with open(file_path, "rb") as f:

        mm = mmap.mmap(f.fileno(), length=0, access=mmap.ACCESS_READ)

        for line in iter(mm.readline, b""):

            if not line.startswith(b' '):  # skip headers
                current_word = line.split(b' ')[0].decode('utf-8')

                # Only keep normal alphabetic words
                if current_word.isalpha():
                    wordnet_words.add(current_word.lower())

        mm.close()


# Load all WordNet words
for word_type in ["adj", "adv", "noun", "verb"]:
    load_wordnet_words(word_type)


# Compare against enable1.txt
enable_path = r"C:\Users\sethr\backup\Desktop\Blurbby\wn3.1.dict\dict\enable1.txt"

missing_words = []

with open(enable_path, "r") as f:
    for line in f:
        word = line.strip().lower()

        if word not in wordnet_words:
            missing_words.append(word)


print(f"Words in ENABLE1 but not WordNet: {len(missing_words)}")
# print(missing_words)


# Save results
with open("enable_not_in_wordnet.txt", "w") as f:
    for word in missing_words:
        f.write(word + "\n")