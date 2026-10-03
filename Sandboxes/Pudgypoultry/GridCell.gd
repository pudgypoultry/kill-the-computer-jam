extends Node2D
class_name GridCell

@export_category("Game Rules")
@export var active : bool = true
@export var examine : Array[String] = ["THIS", "IS", "A", "PLACE", "OF", "HONOR"]
@export var needs_kneel : bool = false
@export var needs_grovel : bool = false
@export var grid_position : Vector2i = Vector2i.ZERO
@export var adjacencies : Array[GridCell]
@export var has_skeleton : bool = false

@export_category("Plugging in Nodes")
@export var sprite : Sprite2D

var grid_manager : GridManager = null



func _ready() -> void:
	if !active:
		for img in get_children():
			img.hide()


func is_adjacent(pos : Vector2i):
	if pos in grid_manager.position_dict.keys():
		return grid_manager.position_dict[pos] in adjacencies
	else:
		return false
