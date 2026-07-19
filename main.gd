extends Node2D

#var draw_bag: Array[String] = [ # "LetterPoints"
	#"A₁","A₂","A₃","A₄","E₁","E₂","E₃","E₄","I₁","I₂","I₃","I₄","O₁","O₂","O₃","O₄","U₁","U₂","U₃","U₄",
	#"A₁","A₂","A₃","A₄","E₁","E₂","E₃","E₄","I₁","I₂","I₃","I₄","O₁","O₂","O₃","O₄","U₁","U₂","U₃","U₄",
	#"B₁","C₁","D₁","F₁","G₁","H₁","J₁","K₁","L₁","M₁","N₁","P₁","Q₁","R₁","S₁","T₁","V₁","W₁","X₁","Y₁","Z₇",	
	#"B₄","C₄","D₄","F₄","G₄","H₄","J₄","K₄","L₄","M₄","N₄","P₄","Q₄","R₄","S₄","T₄","V₄","W₄","X₄","Y₄","Z₇",
	#"B₇","C₇","D₇","F₇","G₇","H₇","J₇","K₇","L₇","M₇","N₇","P₇","Q₇","R₇","S₇","T₇","V₇","W₇","X₇","Y₇","Z₇",
	#"★₉", "★₉", "☆₉", "☆₉" # random vowel (☆₉, includes Y) 9 points, random consonant ("★₉", includes Y) 9 points
#]

var draw_bag: Array[String] = [
	"A₁","A₁","A₁","A₁","A₁","A₁","B₃","B₃","C₃","C₃","D₂","D₂","D₂","D₂",
	"E₁","E₁","E₁","E₁","E₁","E₁","E₁","E₁","E₁","E₁","F₄","G₂","G₂","G₂",
	"H₄","I₁","I₁","I₁","I₁","J₇","K₅","L₁","L₁","L₁","L₁","M₃","M₃",
	"N₁","N₁","N₁","N₁","O₁","O₁","O₁","O₁","P₃","P₃","Q₇","R₁","R₁",
	"R₁","R₁","S₁","S₁","S₁","S₁","T₁","T₁","T₁","T₁","U₁","U₁","V₄",
	"W₄","X₇","Y₄","Z₇","★₉","★₉","☆₉","☆₉"
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
var subscripts_dict = {"₀": 0, "₁": 1, "₂": 2, "₃": 3, "₄": 4, "₅": 5, "₆": 6, "₇": 7, "₈": 8, "₉": 9}
var board
var straight_row_board_scene = preload("res://straight_row_board.tscn")
var tile_holder_offsets = [
	Vector2(-245, -47), 
	Vector2(-190, -47), 
	Vector2(-135, -47), 
	Vector2(-80, -47), 
	Vector2(-25, -47), 
	Vector2(30, -47), 
	Vector2(85, -47), 
	Vector2(140, -47),
	Vector2(195, -47)
]
var on_holder = { 0: 0, 1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0, 8: 0 }
var scan_word = "__________"
var scan_points = "++++++++++"
var tile_positions = {}
var board_offsets = []
var points = 0
var real_word_mult = 1
var blurbbish_word_mult = 3
var new_word_mult = 5

func _ready():
	$"Draw Bag Number".text = "Draw Bag: %s" %draw_bag.size()
	$"Points Label".text = "Points: %s" %points 	
	$"Result Label".text = "Word: \nType: \nRating: \nPoints: "
	
	make_board(straight_row_board_scene, Vector2(250,250))
	board_offsets = board.get_tile_offsets()
	draw_bag.shuffle()
	
	$"Check Word Button".pressed.connect(check_word_button_pressed)
	
	fill_holder()
	
func _process(delta):
	#print(scan_word)
	#print(scan_points)
	#print(draw_bag.size())	
	#print(on_holder)
	pass
	
func _input(event):
	if event is InputEventKey and event.pressed and not event.echo:
		
		# Enter checks word
		if event.keycode == KEY_ENTER:
			check_word_button_pressed()
			return
		
		# Convert key to lowercase letter
		var typed_letter = char(event.unicode).to_lower()
		
		if typed_letter.length() == 1 and typed_letter in letters:
			add_typed_letter(typed_letter)


func add_typed_letter(letter: String):
	# Find matching tile in holder
	var found_tile = null
	var holder_index = null
	
	for index in on_holder:
		var tile = on_holder[index]
		
		if tile:
			var tile_letter = tile.text[0].to_lower()
			
			if tile_letter == letter:
				found_tile = tile
				holder_index = index
				break
	
	# No matching tile
	if found_tile == null:
		return
	
	# Find first empty board spot
	var board_place = -1
	
	for i in range(board_offsets.size()):
		if not tile_positions.values().has(i):
			board_place = i
			break
	
	# Board full
	if board_place == -1:
		return
	
	# Move tile to board
	found_tile.global_position = board.global_position + board_offsets[board_place]
	
	remove_from_word(found_tile)
	convert_star_tile(found_tile)
	
	scan_word = scan_word.substr(0, board_place) + found_tile.text[0] + scan_word.substr(board_place + 1)
	scan_points = scan_points.substr(0, board_place) + found_tile.text[1] + scan_points.substr(board_place + 1)
	
	tile_positions[found_tile] = board_place
	
	# Remove from holder
	on_holder[holder_index] = 0
	
func fill_holder():
	for i in range(9):
		if draw_bag.is_empty():
			break

		if not on_holder[i]:
			var random_letter = draw_bag.pick_random()
			on_holder[i] = create_letter_tile(random_letter, tile_holder_offsets[i] + $TileHolder.position)
			draw_bag.erase(random_letter)

	$"Draw Bag Number".text = "Draw Bag: %s" % draw_bag.size()

	if game_over():
		$"Result Label".text = "Game Over"
		$"Check Word Button".disabled = true
	
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

func tile_released(tile):
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
		# Convert random tiles into permanent letters
		convert_star_tile(tile)

		scan_word = scan_word.substr(0, place) + tile.text[0] + scan_word.substr(place + 1)
		scan_points = scan_points.substr(0, place) + tile.text[1] + scan_points.substr(place + 1)
		tile_positions[tile] = place
		var holder_index = on_holder.find_key(tile)
		if holder_index != null:
			on_holder[holder_index] = 0
			
	else:
		remove_from_word(tile)
		return_tile_to_holder(tile)
		
func clear_board():
	for tile in tile_positions.keys():
		tile.queue_free()
	
	tile_positions.clear()
	scan_word = "__________"
	scan_points = "++++++++++"
	
func return_tile_to_holder(tile):
	for index in on_holder:
		if not on_holder[index] or on_holder[index] == tile:
			on_holder[index] = tile
			tile.global_position = tile_holder_offsets[index] + $TileHolder.global_position
			return
			
func remove_from_word(tile):
	if tile in tile_positions:
		var old_place = tile_positions[tile]
		scan_word = scan_word.substr(0, old_place) + "_" + scan_word.substr(old_place + 1)
		scan_points = scan_points.substr(0, old_place) + "+" + scan_points.substr(old_place + 1)
		tile_positions.erase(tile)
		
func check_word_button_pressed():
	
	var word = remove_trailing_symbol(scan_word, "_")
	var numbers = remove_trailing_symbol(scan_points, "+")
	
	if word.contains("_") or word == "":
		$"Result Label".text = "No word detected"
	else:
		if not (word.length() == 1):
			var result = Wordish.get_wordish(word)
			var type_dict = {0: "Real", 1: "Blurbbish", 2: "New"}
			var type = type_dict[result[0]]
			var score = result[1]
			var word_points = 0
			
			if result[0] == 0: #Real word
				for number in numbers:
					word_points += subscripts_dict[number]
				points *= real_word_mult
				points += word_points
				
			elif result[0] == 1: #Blurbbish word
				for number in numbers:
					word_points += subscripts_dict[number]
				word_points *= blurbbish_word_mult
				points += word_points
				
			else: #New word
				if score >= 50:
					for number in numbers:
						# give poitns if the word passed
						word_points += int(subscripts_dict[number] * new_word_mult * (score / 100))
				else:
					for number in numbers:
						# take away points if the word didn't pass
						word_points += -int(subscripts_dict[number] * new_word_mult * (1 - (score / 100)))
				points += word_points
				
			$"Result Label".text = "Word: %s\nType: %s\nRating: %.2f%%\nPoints: %s" % [word, type, score, word_points]
			$"Points Label".text = "Points: %s" % points
			clear_board()
			fill_holder()
		else:
			$"Result Label".text = "Must be longer than one letter"
			clear_board()
			fill_holder()		
		
func remove_trailing_symbol(word: String, symbol: String) -> String:
	while word.begins_with(symbol):
		word = word.substr(1)
	
	while word.ends_with(symbol):
		word = word.substr(0, word.length() - 1)
	
	return word
	
func convert_star_tile(tile):
	if tile.text[0] == "★":
		tile.text = random_consonants.pick_random().to_upper() + "₉"
	elif tile.text[0] == "☆":
		tile.text = random_vowels.pick_random().to_upper() + "₉"
	
func game_over() -> bool:
	if not draw_bag.is_empty():
		return false

	for tile in on_holder.values():
		if tile:
			return false

	if not tile_positions.is_empty():
		return false

	return true
