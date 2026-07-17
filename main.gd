extends Node2D

var draw_bag: Array[String] = [ # "LetterPoints"
	"A₁","A₂","A₃","A₄","E₁","E₂","E₃","E₄","I₁","I₂","I₃","I₄","O₁","O₂","O₃","O₄","U₁","U₂","U₃","U₄",
	"B₁","C₁","D₁","F₁","G₁","H₁","J₁","K₁","L₁","M₁","N₁","P₁","Q₁","R₁","S₁","T₁","V₁","W₁","X₁","Y₁","Z₁",
	"B₄","C₄","D₄","F₄","G₄","H₄","J₄","K₄","L₄","M₄","N₄","P₄","Q₄","R₄","S₄","T₄","V₄","W₄","X₄","Y₄","Z₄",
	"B₇","C₇","D₇","F₇","G₇","H₇","J₇","K₇","L₇","M₇","N₇","P₇","Q₇","R₇","S₇","T₇","V₇","W₇","X₇","Y₇","Z₇",
	"★₉", "★₉", "☆₉", "☆₉" # random vowel (☆₉, includes Y) 9 points, random consonant ("★₉", includes Y) 9 points
]
var random_vowels: Array[String] = ["a", "e", "i", "o", "u", "y"]
var random_consonants: Array[String] = [
	"b","c","d","f","g","h","j","k","l","m","n","p","q","r","s","t","v","w","x","y","z"
]
var discard_bag: Array[String] = []
var player1_hand: Array[String] = []
var player2_hand: Array[String] = []
var letter_scene = preload("res://letter_tile.tscn")
var letters = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]
var subscripts = ["₀", "₁", "₂", "₃", "₄", "₅", "₆", "₇", "₈", "₉"]
var straight_row_board_scene = preload("res://straight_row_board.tscn")

func _ready():
	
	make_board(straight_row_board_scene, Vector2(0,0))
	
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
	
	for i in range(0, 7):
		var random_letter = draw_bag.pick_random()
		create_letter_tile(random_letter, Vector2((i-3)*55-25, -47) + $TileHolder.position)
	
func create_letter_tile(text_value: String, postion: Vector2):
	var new_tile = letter_scene.instantiate()
	new_tile.text = text_value.to_upper()
	new_tile.position = postion
	add_child(new_tile)
	
func make_board(board_scene: PackedScene, position: Vector2):
	var new_board = board_scene.instantiate()
	new_board.position = position
	add_child(new_board)

func deconstruct_wordish(word: String, type: int, score: float):

	print("Word: ", word)
	print("Type: ", type)
	print("Score: ", score)
