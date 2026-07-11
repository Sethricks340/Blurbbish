

import mmap

bi_dict = {}
tri_dict = {}
quad_dict = {}
quint_dict = {}

def search_dictionary(data_type):
    file_path = fr"C:\Users\sethr\backup\Desktop\Blurbby\wn3.1.dict\dict\index.{data_type}"

    with open(file_path, "rb") as f:
        
        line_count = sum(1 for _ in f) # get line count for iteration
        f.seek(0) # move cursor back to beginning
  
        mm = mmap.mmap(f.fileno(), length=0, access=mmap.ACCESS_READ)

        for _ in range(line_count):

            line = mm.readline()
            
            if not line.startswith(b' '): # skip headers
                current_word = line.split(b' ')[0].decode('utf-8')

                # Skip word if it contains punctuation, numbers, or symbols
                if not current_word.isalpha():
                    continue

                for group in range(2, 6):

                    if group == 2: dictionary = bi_dict
                    elif group == 3: dictionary = tri_dict
                    elif group == 4: dictionary = quad_dict
                    elif group == 5: dictionary = quint_dict

                    for index in range(len(current_word) - (group - 1)):
                        pair = current_word[index:index + group]

                        if pair in dictionary:
                            dictionary[pair] += 1
                        else:
                            dictionary[pair] = 1


        mm.close()


def find_min_max(dictionary):
    min_val = 99999
    max_val = -1
    min_pair = ""
    max_pair = ""

    for key, var in dictionary.items():
        if var < min_val:
            min_pair = key
            min_val = var
        if var > max_val:
            max_pair = key
            max_val = var

    print(f"key: {min_pair}", f" min: {min_val}")
    print(f"key: {max_pair}", f" max: {max_val}")  


for word_type in ["adj", "adv", "noun", "verb"]:
    search_dictionary(word_type)

find_min_max(bi_dict)
find_min_max(tri_dict)
find_min_max(quad_dict)
find_min_max(quint_dict)

# import json

# with open(r"bi_dict.json", "w") as f:
#     json.dump(bi_dict, f)

# with open("tri_dict.json", "w") as f:
#     json.dump(tri_dict, f)

# with open("quad_dict.json", "w") as f:
#     json.dump(quad_dict, f)

# with open("quint_dict.json", "w") as f:
#     json.dump(quint_dict, f)