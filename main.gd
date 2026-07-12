extends Node2D

func _ready():

	var word = "ulvren"

	var score = Wordish.wordish_score(word)
	#var score = Wordish.test_words_menu()

	print("Word: ", word)
	print("Score: ", score)

	if score > 50:
		print("Looks like a real word")
	else:
		print("Looks fake")
