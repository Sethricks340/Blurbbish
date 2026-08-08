extends Node2D

var draw_bag: Array[String] 

var draw_bag_original: Array[String] = [
	#"B₁","L₁","U₁","R₁","B₁","B₁","I₁","S₁","H₁",
	"A₁","A₁","A₁","A₁","A₁","A₁","B₃","B₃","C₃","C₃","D₂","D₂","D₂","D₂",
	"E₁","E₁","E₁","E₁","E₁","E₁","E₁","E₁","E₁","E₁","F₄","G₂","G₂","G₂",
	"H₄","I₁","I₁","I₁","I₁","J₇","K₅","L₁","L₁","L₁","L₁","M₃","M₃",
	"N₁","N₁","N₁","N₁","O₁","O₁","O₁","O₁","P₃","P₃","Q₇","R₁","R₁",
	"R₁","R₁","S₁","S₁","S₁","S₁","T₁","T₁","T₁","T₁","U₁","U₁","V₄",
	"W₄","X₇","Y₄","Z₇",
	#"★₉","★₉","☆₉","☆₉" # random vowel (☆₉, includes Y) 9 points, random consonant ("★₉", includes Y) 9 points
	]

var on_holder 
var scan_word 
var scan_points 
var game_finished 
var tile_positions 

var random_vowels: Array[String] = ["a", "e", "i", "o", "u", "y"]
var random_consonants: Array[String] = [
	"b","c","d","f","g","h","j","k","l","m","n","p","q","r","s","t","v","w","x","y","z"
]
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
var board_offsets = []
var points = 0
var real_word_mult = 1
var blurbbish_word_mult = 3
var new_word_mult = 5
var high_score = - INF
var timer_time = 60
var blurbbish_dict = {}
var new_words = []

func _ready():
	load_blurbbish()
	draw_bag = draw_bag_original.duplicate()

	on_holder = { 0: 0, 1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0, 8: 0 }
	scan_word = "__________"
	scan_points = "++++++++++"
	game_finished = false
	tile_positions = {}
		
	
	$"Game Timer".wait_time = timer_time
	$"Game Timer".one_shot = true
	$"Game Timer".start()
	$"Game Timer".timeout.connect(timer_finished)
	$"Draw Bag Number".text = "Draw Bag: %s" %draw_bag.size()
	$"Points Label".text = "Points: %s" %points 	
	$"Result Label".text = "Word: \nType: \nRating: \nPoints: "
	$"High Score".text = "High Score: 0"
	$"Game Over Label".text = ""
	
	make_board(straight_row_board_scene, Vector2(250,250))
	board_offsets = board.get_tile_offsets()
	draw_bag.shuffle()
	
	$"Check Word Button".pressed.connect(check_word_button_pressed)
	$"Play Again Button".pressed.connect(restart_game)
	$"Play Again Button".disabled = true
	
	fill_holder()
	
func _process(delta):
	if not game_finished:
		$"Timer Label".text = "Time: %d" % ceil($"Game Timer".time_left)
	
func load_blurbbish():
	var file = FileAccess.open("res://Data/blurbbish_dictionary.json", FileAccess.READ)
	blurbbish_dict = JSON.parse_string(file.get_as_text())
	file.close()
		
func add_blurbbish_word(word: String):
	if not blurbbish_dict.has(word):
		blurbbish_dict[word] = ["A word created by a player"]

		save_blurbbish()
		
func save_blurbbish():
	var file = FileAccess.open("res://Data/blurbbish_dictionary.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(blurbbish_dict, "\t"))
	file.close()
	
func timer_finished():
	end_game("Time's Up!")
	
func _input(event):
	if game_finished:
		return
		
	if event is InputEventKey and event.pressed and not event.echo:
		
		if event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:
			check_word_button_pressed()
			get_viewport().set_input_as_handled()
			return
		
		if event.keycode == KEY_BACKSPACE:
			remove_last_letter()
			get_viewport().set_input_as_handled()
			return
		
		var typed_letter = char(event.unicode).to_lower()
		
		if typed_letter.length() == 1 and typed_letter in letters:
			add_typed_letter(typed_letter)
			get_viewport().set_input_as_handled()

func remove_last_letter():
	if tile_positions.is_empty():
		return
	
	# Find the rightmost tile
	var rightmost_tile = null
	var rightmost_position = -1
	
	for tile in tile_positions:
		var position = tile_positions[tile]
		
		if position > rightmost_position:
			rightmost_position = position
			rightmost_tile = tile
	
	if rightmost_tile:
		remove_from_word(rightmost_tile)
		return_tile_to_holder(rightmost_tile)

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
		end_game("Game Over")
	
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
						new_words.append(word)
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
	
func end_game(message: String):
	if game_finished:
		return

	game_finished = true
	$"Game Timer".stop()
	$"Timer Label".text = "Time: 0"
	$"Game Over Label".text = "%s\nFinal Score: %d" % [message, points]
	$"Check Word Button".disabled = true

	high_score = max(high_score, points)
	$"High Score".text = "High Score: %d" % high_score
	
	$"Play Again Button".disabled = false
	
	for word in new_words:
		add_blurbbish_word(word)
	new_words.clear()

func restart_game():
	# Remove existing holder tiles
	for tile in on_holder.values():
		if tile:
			tile.queue_free()

	clear_board()

	draw_bag = draw_bag_original.duplicate()
	draw_bag.shuffle()

	on_holder = {0:0,1:0,2:0,3:0,4:0,5:0,6:0,7:0,8:0}
	scan_word = "__________"
	scan_points = "++++++++++"
	tile_positions = {}
	points = 0
	game_finished = false

	$"Points Label".text = "Points: 0"
	$"Result Label".text = "Word:\nType:\nRating:\nPoints:"
	$"Draw Bag Number".text = "Draw Bag: %d" % draw_bag.size()

	$"Check Word Button".disabled = false
	$"Play Again Button".disabled = true
	$"Game Over Label".text = ""

	$"Game Timer".start(timer_time)

	fill_holder()
