import mmap
import os
import json


word_definitions = {}


def get_definition(index_line, data_type):
    data_file_path = fr"C:\Users\sethr\backup\Desktop\Blurbby\wn3.1.dict\dict\data.{data_type}"

    tokens = index_line.split()
    offsets = [t for t in tokens if t.isdigit() and len(t) == 8]

    definitions = []

    with open(data_file_path, "rb") as f:
        for offset_str in offsets:
            offset = int(offset_str)

            f.seek(offset)
            raw_data_line = f.readline().decode("utf-8").strip()

            if "|" in raw_data_line:
                full_gloss = raw_data_line.split("|")[1].strip()

                # Remove example sentences
                definition_only = full_gloss.split(";")[0].strip()

                definitions.append(definition_only)

    return definitions


def process_dictionary(data_type):
    index_file_path = fr"C:\Users\sethr\backup\Desktop\Blurbby\wn3.1.dict\dict\index.{data_type}"

    if not os.path.exists(index_file_path):
        return

    with open(index_file_path, "rb") as f:
        mm = mmap.mmap(f.fileno(), length=0, access=mmap.ACCESS_READ)

        for line in iter(mm.readline, b""):

            # Skip headers
            if line.startswith(b" "):
                continue

            decoded_line = line.decode("utf-8").strip()

            word = decoded_line.split()[0].lower()

            # Only keep words containing a-z characters
            if not word.isascii() or not word.isalpha():
                continue

            definitions = get_definition(decoded_line, data_type)

            if definitions:
                if word in word_definitions:
                    word_definitions[word].extend(definitions)
                else:
                    word_definitions[word] = definitions

        mm.close()


# Process WordNet files
for word_type in ["adj", "adv", "noun", "verb"]:
    print(f"Processing {word_type}...")
    process_dictionary(word_type)


print(f"Total words exported: {len(word_definitions)}")


# Export as JSON for C#
with open("wordnet_definitions.json", "w", encoding="utf-8") as f:
    json.dump(word_definitions, f, indent=4, ensure_ascii=False)


print("Finished exporting.")