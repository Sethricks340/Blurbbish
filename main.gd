extends Node2D

var draw_bag: Array[String] = [ # "LetterPoints"
	"A₁","A₂","A₃","A₄","E₁","E₂","E₃","E₄","I₁","I₂","I₃","I₄","O₁","O₂","O₃","O₄","U₁","U₂","U₃","U₄",
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
var board
var straight_row_board_scene = preload("res://straight_row_board.tscn")
var tile_holder_offsets = [
	Vector2(-190, -47), 
	Vector2(-135, -47), 
	Vector2(-80, -47), 
	Vector2(-25, -47), 
	Vector2(30, -47), 
	Vector2(85, -47), 
	Vector2(140, -47)
]
var on_holder = {}
var scan_word = "__________"
var tile_positions = {}
var board_offsets = []

func _ready():
	
	make_board(straight_row_board_scene, Vector2(250,250))
	board_offsets = board.get_tile_offsets()
	draw_bag.shuffle()
	
	$"Check Word Button".pressed.connect(check_word_button_pressed)
	
	for i in range(0, 7):
		var random_letter = draw_bag.pick_random()
		on_holder[i]  = create_letter_tile(random_letter, tile_holder_offsets[i] + $TileHolder.position)
	
func _process(delta):
	#print(scan_word)
	pass
	
func create_letter_tile(text_value: String, postion: Vector2):
	var new_tile = letter_scene.instantiate()
	new_tile.text = text_value.to_upper()
	new_tile.position = postion
	new_tile.tile_released.connect(tile_released)
	add_child(new_tile)
	return new_tile
	
func make_board(board_scene: PackedScene, position: Vector2):
	board = board_scene.instantiate()
	board.position = position
	add_child(board)

func print_wordish(word: String, type: int, score: float):

	print("Word: ", word)
	print("Type: ", type)
	print("Score: ", score)

func tile_released(tile):
	$"Result Label".text = "Score: "
	var closest_distance = INF
	var closest_position = null
	
	var place
	for offset in board_offsets:
		var board_position = board.global_position + offset
		var distance = tile.global_position.distance_to(board_position)
		
		if distance < closest_distance:
			closest_distance = distance
			closest_position = board_position
			place = board_offsets.find(offset)
	
	# check space not taken
	if closest_distance < 40 and not tile_positions.values().has(place):
		tile.global_position = closest_position
		remove_from_word(tile)
		scan_word = scan_word.substr(0, place) + tile.text[0] + scan_word.substr(place + 1)
		tile_positions[tile] = place
			
	else:
		remove_from_word(tile)
		return_tile_to_holder(tile)
		
func return_tile_to_holder(tile):
	for index in on_holder:
		if on_holder[index] == tile:
			tile.global_position = tile_holder_offsets[index] + $TileHolder.global_position
			return
			
func remove_from_word(tile):
	if tile in tile_positions:
		var old_place = tile_positions[tile]
		scan_word = scan_word.substr(0, old_place) + "_" + scan_word.substr(old_place + 1)
		tile_positions.erase(tile)
		
# doesn't work with the star random symbols
func check_word_button_pressed():
	
	var word = remove_trailing_underscores(scan_word)
	
	if word.contains("_") or word == "":
		$"Result Label".text = "No word detected"
	else:
		var result = Wordish.get_wordish(word)
		var type = result[0]
		var score = result[1]
		$"Result Label".text = "Score: %.2f%%" % score
		
		#print_wordish(word, type, score)
	
func remove_trailing_underscores(word: String) -> String:
	while word.begins_with("_"):
		word = word.substr(1)
	
	while word.ends_with("_"):
		word = word.substr(0, word.length() - 1)
	
	return word
