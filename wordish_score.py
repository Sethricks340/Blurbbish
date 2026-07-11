import json, math, os

def clear_terminal(): 
    os.system('cls' if os.name == 'nt' else 'clear')

max_counts = [12847, 3823, 2558, 1796] # er, ing, tion, ation are the patterns most found
gram_weights = [5, 9, 5, 2] # bigram, trigram, quadgram, quintgram

with open(r"C:\Users\sethr\backup\Desktop\Blurbby\dicts\wordnet_definitions.json", "r", encoding="utf-8") as f:
    word_definitions = json.load(f)
with open(r"C:\Users\sethr\backup\Desktop\Blurbby\dicts\blurbbinary.json", "r", encoding="utf-8") as f:
    blurbbinary = json.load(f)
with open(r"C:\Users\sethr\backup\Desktop\Blurbby\dicts\test_words.json", "r") as f:
    test_words = json.load(f)

# with open(r"C:\Users\sethr\backup\Desktop\Blurbby\dicts\bi_dict.json", "r", encoding="utf-8") as f:
#     bi_dict = json.load(f)
# with open(r"C:\Users\sethr\backup\Desktop\Blurbby\dicts\tri_dict.json", "r", encoding="utf-8") as f:
#     tri_dict = json.load(f)
# with open(r"C:\Users\sethr\backup\Desktop\Blurbby\dicts\quad_dict.json", "r", encoding="utf-8") as f:
#     quad_dict = json.load(f)
# with open(r"C:\Users\sethr\backup\Desktop\Blurbby\dicts\quint_dict.json", "r", encoding="utf-8") as f:
#     quint_dict = json.load(f)
# with open(r"C:\Users\sethr\backup\Desktop\Blurbby\dicts\bi_dict_position.json", "r", encoding="utf-8") as f:
#     bi_dict_positions = json.load(f)
# with open(r"C:\Users\sethr\backup\Desktop\Blurbby\dicts\tri_dict_position.json", "r", encoding="utf-8") as f:
#     tri_dict_positions = json.load(f)
# with open(r"C:\Users\sethr\backup\Desktop\Blurbby\dicts\quad_dict_position.json", "r", encoding="utf-8") as f:
#     quad_dict_positions = json.load(f)
# with open(r"C:\Users\sethr\backup\Desktop\Blurbby\dicts\quint_dict_position.json", "r", encoding="utf-8") as f:
#     quint_dict_positions = json.load(f)

with open(r"C:\Users\sethr\backup\Desktop\Blurbby\dicts\grams.json", "r", encoding="utf-8") as f:
    grams_dict = json.load(f)

def get_gram_scores(word):
    """Return existence of the gram in English scores and frequency scores for a word"""

    weighted_freq_scores = []
    weighted_existing_scores = []
    grams = {}

    for group in range(2, 6): #2 to 5

        for index in range(len(word) - (group - 1)):

            letters = word[index:index + group]

            if letters in grams_dict:

                weighted_existing_scores.append(
                    gram_weights[group - 2]
                )

                weighted_freq_score = (
                    math.log(sum(grams_dict[letters].values()) + 1) / 
                    math.log(max_counts[group - 2] + 1)
                )

                weighted_freq_scores.append(
                    weighted_freq_score * gram_weights[group - 2]
                )

            else:

                weighted_existing_scores.append(0)
                weighted_freq_scores.append(0)

            if letters in grams:
                grams[letters] += 1
            else:
                grams[letters] = 0

    denominator = sum(
        gram_weights[group - 2]
        for group in range(2, 6)
        for _ in range(len(word) - (group - 1))
    )

    existing_score = (
        sum(weighted_existing_scores) /
        denominator *
        100
    )

    frequency_score = (
        sum(weighted_freq_scores) /
        denominator *
        100
    )

    return existing_score, frequency_score, grams

def repetition_score(grams):
    """Penalize repeated grams in the word"""

    score = 0

    for key, value in grams.items():
        score += value

    if score == 0:
        return 0
    elif score > 5:
        return -50
    else:
        return -15

def repeated_letter_score(word):
    """Return a penalty if the word contains three identical letters in a row"""

    repeat_count = 1

    for i in range(1, len(word)):

        if word[i] == word[i-1]:
            repeat_count += 1
        else:
            repeat_count = 1
        if repeat_count >= 3:
            return -100
    return 0

def vowel_consonant_score(word):
    """Return a penalty if the word has only vowels or only consonants"""

    vowels = "aeiou"
    vowel_count = 0
    consonant_count = 0

    for letter in word:
        if letter in vowels:
            vowel_count += 1
        else:
            consonant_count += 1
    if vowel_count == 0 or consonant_count == 0:
        return -100
    return 0

def gram_locations_score(word, grams):
    """Score and penalize grams by their typical position in real words"""

    penalties = []

    for gram in grams:
        length = len(gram)

        # only bigram and trigrams, since most quadgrams and quintgrams won't exist
        if not (length == 2 or length == 3):
            continue 
        else:
            start = word.index(gram)
            end = start + len(gram)

            if start == 0 and end == len(word):
                position = "middle"

            elif start == 0:
                position = "beginning"

            elif end == len(word):
                position = "end"

            else:
                position = "middle"

            if gram in grams_dict:

                count = grams_dict[gram][position]
                total = sum(grams_dict[gram].values())
                probability = count / total
                penalty = math.log10(probability + 0.01) * 20
                penalties.append(penalty)
            else: 
                #if a bi or tri gram doesn't exist entirely, punish it greatly
                penalties.append(-200)

    if not penalties:
        return 0

    return sum(penalties) / len(penalties)

def zword_score(word):
    # Remove z from beginning
    if word.startswith("z") and word[1:] in word_definitions:
        return 0

    # Remove z from end
    if word.endswith("z") and word[:-1] in word_definitions:
        return 0

    # Remove all trailing z's
    stripped = word.rstrip("z")
    if stripped != word and stripped in word_definitions:
        return 0

    # Remove doubled z
    if "zz" in word:
        if word.replace("zz", "ss") in word_definitions:
            return 0

    # Replace z with "es"
    if word.replace("z", "es") in word_definitions:
        return 0
    
    # Replace z with "gs"
    if word.replace("z", "gs") in word_definitions:
        return 0
    
    # Replace z with "g"
    if word.replace("z", "g") in word_definitions:
        return 0

    # Remove z's and check if the base word exists
    no_z = word.replace("z", "")
    if no_z != word and no_z in word_definitions:
        return 0

    return 100

def wordish_score(word):
    """Combine gram-based evidence and penalties into a single score"""

    if not zword_score(word): return 0

    existing_score, frequency_score, grams = get_gram_scores(word)
    repeat_penalty = repetition_score(grams)
    triple_penalty = repeated_letter_score(word)
    vowel_penalty = vowel_consonant_score(word)
    gram_location_penalty = gram_locations_score(word, grams)

    # Positive evidence
    score = (
        existing_score * 0.5 +
        frequency_score * 0.5
    )

    # Negative evidence
    score += repeat_penalty
    score += triple_penalty
    score += vowel_penalty
    score += gram_location_penalty

    return max(score, 0)





if input("manual? (y=manual, n=from json): ").lower() == "y":

    while True:

        word = input("\nEnter word: ").lower().strip()
        
        if word not in test_words:
            test_words.append(word)

            with open(r"C:\Users\sethr\backup\Desktop\Blurbby\dicts\test_words.json", "w") as f:
                json.dump(test_words, f, indent=4)

        if word in word_definitions:
            print("\nREAL WORD")
            print(word)
            for i, meaning in enumerate(word_definitions[word], 1):
                print(f"{i}. {meaning}")
            continue

        score = wordish_score(word)

        if score <= 50:
            print(f"\nFAILED: {score:.2f}")
        else:
            print(f"\nPASSED: {score:.2f}")

        existing_score, frequency_score, grams = get_gram_scores(word)
        z_word_score = zword_score(word)
        print(f"z_word_score: {z_word_score:.2f}")
        print(f"existing score: {existing_score:.2f}")
        print(f"frequency score: {frequency_score:.2f}")
        print(f"grams: {list(grams.keys())}")
        print(f"repetition penalty: {repetition_score(grams):.2f}")
        print(f"triple letter penalty: {repeated_letter_score(word):.2f}")
        print(f"vowel penalty: {vowel_consonant_score(word):.2f}")
        print(f"gram location penalty: {gram_locations_score(word, grams):.2f}")

else:


    fail_words = []
    pass_words = []
    real_words = []
    blurbbs = []


    for word in test_words:

        if word in word_definitions:
            real_words.append(word)

        elif word in blurbbinary:
            blurbbs.append(word)

        else:
            score = wordish_score(word)

            if score <= 50:
                fail_words.append((word, score))
            else:
                pass_words.append((word, score))


    print("\n")
    print("passed words:")

    for word, score in sorted(pass_words):
        print(f"{word:<20} {score:>6.2f}")


    print("\n")
    print("failed words:")

    for word, score in sorted(fail_words):
        print(f"{word:<20} {score:>6.2f}")


    print("\n")
    print("real words:")

    for word in sorted(real_words):
        print(word)

        for i, meaning in enumerate(word_definitions[word], 1):
            print(f"{i}. {meaning}")
    
    print("\n")
    print("blurbbs:")

    for word in sorted(blurbbs):
        print(word)

        for i, meaning in enumerate(blurbbinary[word], 1):
            print(f"{i}. {meaning}")
