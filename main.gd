extends Node2D

func _ready():

	var word_list = ["hello", "blurbb", "ulvren", "twizzle"]

	for word in word_list:
		var result = Wordish.get_wordish(word)
		var type = result[0]
		var score = result[1]
		
		deconstruct_wordish(word, type, score)


func deconstruct_wordish(word: String, type: int, score: float):

	print("Word: ", word)
	print("Type: ", type)
	print("Score: ", score)
