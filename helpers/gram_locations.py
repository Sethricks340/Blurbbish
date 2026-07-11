import mmap

bi_dict = {}
tri_dict = {}
quad_dict = {}
quint_dict = {}


def get_position(index, word_length, gram_length):
    """
    Returns where the gram appears in the word:
    beginning, middle, or end
    """

    if index == 0:
        return "beginning"

    elif index + gram_length == word_length:
        return "end"

    else:
        return "middle"



def add_gram(dictionary, gram, position):

    if gram not in dictionary:
        dictionary[gram] = {
            "beginning": 0,
            "middle": 0,
            "end": 0
        }

    dictionary[gram][position] += 1



def search_dictionary(data_type):

    file_path = fr"C:\Users\sethr\backup\Desktop\Blurbby\wn3.1.dict\dict\index.{data_type}"

    with open(file_path, "rb") as f:

        line_count = sum(1 for _ in f)
        f.seek(0)

        mm = mmap.mmap(f.fileno(), length=0, access=mmap.ACCESS_READ)

        for _ in range(line_count):

            line = mm.readline()

            if not line.startswith(b' '):

                current_word = line.split(b' ')[0].decode('utf-8')

                if not current_word.isalpha():
                    continue


                for group in range(2, 6):

                    if group == 2:
                        dictionary = bi_dict
                    elif group == 3:
                        dictionary = tri_dict
                    elif group == 4:
                        dictionary = quad_dict
                    elif group == 5:
                        dictionary = quint_dict


                    for index in range(len(current_word) - (group - 1)):

                        gram = current_word[index:index + group]

                        position = get_position(
                            index,
                            len(current_word),
                            group
                        )

                        add_gram(dictionary, gram, position)


        mm.close()



for word_type in ["adj", "adv", "noun", "verb"]:
    search_dictionary(word_type)

import json

with open("bi_dict_position.json", "w", encoding="utf-8") as f:
    json.dump(bi_dict, f, indent=4)

with open("tri_dict_position.json", "w", encoding="utf-8") as f:
    json.dump(tri_dict, f, indent=4)

with open("quad_dict_position.json", "w", encoding="utf-8") as f:
    json.dump(quad_dict, f, indent=4)

with open("quint_dict_position.json", "w", encoding="utf-8") as f:
    json.dump(quint_dict, f, indent=4)