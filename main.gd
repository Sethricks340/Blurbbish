extends Node2D

var draw_bag: Array[String] = [ # "LetterPoints"
	"a1","a2","a3","a4","e1","e2","e3","e4","i1","i2","i3","i4","o1","o2","o3","o4","u1","u2","u3","u4",
	"b1","c1","d1","f1","g1","h1","j1","k1","l1","m1","n1","p1","q1","r1","s1","t1","v1","w1","x1","y1","z1",
	"b4","c4","d4","f4","g4","h4","j4","k4","l4","m4","n4","p4","q4","r4","s4","t4","v4","w4","x4","y4","z4",
	"b7","c7","d7","f7","g7","h7","j7","k7","l7","m7","n7","p7","q7","r7","s7","t7","v7","w7","x7","y7","z7",
	"_rv9", "_rc9", "_rv9", "_rc9" # random vowel (includes y) 9 points, random consonant (includes y) 9 points
]
var random_vowels: Array[String] = ["a", "e", "i", "o", "u", "y"]
var random_consonants: Array[String] = [
	"b","c","d","f","g","h","j","k","l","m","n","p","q","r","s","t","v","w","x","y","z"
]
var discard_bag: Array[String] = []
var player1_hand: Array[String] = []
var player2_hand: Array[String] = []

func _ready():
	
	draw_bag.shuffle()
	
	for i in range(6):
		var letter: String = draw_bag[i]
		player1_hand.append(letter)
		draw_bag.erase(letter)
	
	print(player1_hand)

	#var test_word = "koxil"
	var test_word = "vowt"
	var random_index = randi_range(0, test_word.length() - 1)
	test_word = test_word.substr(0, random_index) + random_consonants.pick_random() + test_word.substr(random_index + 1)
	var result = Wordish.get_wordish(test_word)
	var type = result[0]
	var score = result[1]
	
	deconstruct_wordish(test_word, type, score)


func deconstruct_wordish(word: String, type: int, score: float):

	print("Word: ", word)
	print("Type: ", type)
	print("Score: ", score)
