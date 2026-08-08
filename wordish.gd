extends Node

var max_counts = [40163, 15754, 6764, 4796] # er, ing, tion, ation are the patterns most found
var gram_weights = [5, 9, 5, 2] # bigram, trigram, quadgram, quintgram

var word_definitions = {}
var blurbbish_dictionary = {}
var test_words = {}
var grams_dict = {}

func _ready():
	load_data()


func load_data():
	var english_file = FileAccess.open("res://Data/english_dictionary.json", FileAccess.READ)
	word_definitions = JSON.parse_string(english_file.get_as_text())
	english_file.close()

	var blurbbish_dictionary_file = FileAccess.open("res://Data/blurbbish_dictionary.json", FileAccess.READ)
	blurbbish_dictionary = JSON.parse_string(blurbbish_dictionary_file.get_as_text())
	blurbbish_dictionary_file.close()

	var test_words_file = FileAccess.open("res://Data/test_words.json", FileAccess.READ)
	test_words = JSON.parse_string(test_words_file.get_as_text())
	test_words_file.close()

	var grams_file = FileAccess.open("res://Data/grams.json", FileAccess.READ)
	grams_dict = JSON.parse_string(grams_file.get_as_text())
	grams_file.close()

func get_gram_scores(word: String):
	# Return existence of the gram in English scores and frequency scores for a word

	var weighted_freq_scores = []
	var weighted_existing_scores = []
	var grams = {}

	for group in range(2, 6): # 2 to 5

		for index in range(word.length() - (group - 1)):

			var letters = word.substr(index, group)

			if grams_dict.has(letters):

				weighted_existing_scores.append(
					gram_weights[group - 2]
				)

				var total_count = 0

				for value in grams_dict[letters].values():
					total_count += value

				var weighted_freq_score = (
					log(total_count + 1) /
					log(max_counts[group - 2] + 1)
				)

				weighted_freq_scores.append(
					weighted_freq_score * gram_weights[group - 2]
				)

			else:

				weighted_existing_scores.append(0)
				weighted_freq_scores.append(0)


			if grams.has(letters):
				grams[letters] += 1
			else:
				grams[letters] = 0


	var denominator = 0

	for group in range(2, 6):
		for i in range(word.length() - (group - 1)):
			denominator += gram_weights[group - 2]


	var existing_score = (
		float(weighted_existing_scores.reduce(func(a, b): return a + b)) /
		denominator *
		100
	)

	var frequency_score = (
		float(weighted_freq_scores.reduce(func(a, b): return a + b)) /
		denominator *
		100
	)

	return [existing_score, frequency_score, grams]
	
func repetition_score(grams: Dictionary):
	# Penalize repeated grams in the word

	var score = 0

	for key in grams:
		score += grams[key]

	if score == 0:
		return 0
	elif score > 5:
		return -50
	else:
		return -15
		
func repeated_letter_score(word: String):
	# Return a penalty if the word contains three identical letters in a row

	var repeat_count = 1

	for i in range(1, word.length()):

		if word[i] == word[i - 1]:
			repeat_count += 1
		else:
			repeat_count = 1

		if repeat_count >= 3:
			return -100

	return 0
	
func vowel_consonant_score(word: String):
	# Return a penalty if the word has only vowels or only consonants

	var vowels = "aeiou"
	var vowel_count = 0
	var consonant_count = 0

	for letter in word:
		if letter in vowels:
			vowel_count += 1
		else:
			consonant_count += 1

	if vowel_count == 0 or consonant_count == 0:
		return -100

	return 0
	
func gram_locations_score(word: String, grams: Dictionary):
	# Score and penalize grams by their typical position in real words

	var penalties = []

	for gram in grams:

		var length = gram.length()

		# only bigram and trigrams, since most quadgrams and quintgrams won't exist
		if not (length == 2 or length == 3):
			continue

		var start = word.find(gram)
		var end = start + gram.length()

		var position = ""

		if start == 0 and end == word.length():
			position = "middle"

		elif start == 0:
			position = "beginning"

		elif end == word.length():
			position = "end"

		else:
			position = "middle"


		if grams_dict.has(gram):

			var count = grams_dict[gram][position]

			var total = 0
			for value in grams_dict[gram].values():
				total += value

			var probability = float(count) / total
			var penalty = log(probability + 0.01) / log(10) * 20

			penalties.append(penalty)

		else:
			# if a bi or tri gram doesn't exist entirely, punish it greatly
			penalties.append(-200)


	if penalties.is_empty():
		return 0

	var sum = 0.0
	for penalty in penalties:
		sum += penalty

	return sum / penalties.size()
	
func zword_score(word: String):
	# Remove z from beginning
	if word.begins_with("z") and word.substr(1) in word_definitions:
		return 0

	# Remove z from end
	if word.ends_with("z") and word.substr(0, word.length() - 1) in word_definitions:
		return 0

	# Remove all trailing z's
	var stripped = word.rstrip("z")
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

	# Replace z with "s"
	if word.replace("z", "s") in word_definitions:
		return 0
	
	# Remove z's and check if the base word exists
	var no_z = word.replace("z", "")
	if no_z != word and no_z in word_definitions:
		return 0	

	return 100
	
func wordish_score(word: String):
	# Combine gram-based evidence and penalties into a single score

	#if not zword_score(word):
		#return 0

	var result = get_gram_scores(word)

	var existing_score = result[0]
	var frequency_score = result[1]
	var grams = result[2]

	var repeat_penalty = repetition_score(grams)
	var triple_penalty = repeated_letter_score(word)
	var vowel_penalty = vowel_consonant_score(word)
	var gram_location_penalty = gram_locations_score(word, grams)

	# Positive evidence
	var score = (
		existing_score * 0.5 +
		frequency_score * 0.5
	)

	# Negative evidence
	score += repeat_penalty
	score += triple_penalty
	score += vowel_penalty
	score += gram_location_penalty

	return max(score, 0)
	
func get_wordish(word: String):

	word = word.to_lower().strip_edges()

	# 0 = real word, 1 = in Blurbbinary, 2 = new word
	if word_definitions.has(word):
		return [0, 0]

	if blurbbish_dictionary.has(word):
		return [1, 0]

	return [2, wordish_score(word)]
