extends Node2D

var tile_offsets = []

func _ready():
	for child in get_children():
		if child is Panel:
			tile_offsets.append(child.position)

func get_tile_offsets():
	return tile_offsets
