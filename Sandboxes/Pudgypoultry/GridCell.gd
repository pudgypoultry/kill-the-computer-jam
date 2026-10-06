extends Node2D
class_name GridCell

@export_category("Game Rules")
@export var active : bool = true
@export var examine : Array[String] = ["THIS", "IS", "A", "PLACE", "OF", "HONOR"]
@export var needs_kneel : bool = false
@export var needs_grovel : bool = false
@export var grid_position : Vector2i = Vector2i.ZERO
@export var adjacencies : Array[GridCell]
@export var hidden_room : bool = false
@export var has_skeleton : bool = false
@export var is_starting_position : bool = false
@export var is_locked : bool = false
@export var has_password : bool = false
@export var password : Array[String] = ["", ""]
@export var locked_position : GridCell
@export var door_sprite : Sprite2D

@export_category("Plugging in Nodes")
@export var sprite : Sprite2D
@export var skeleton_sprite : Sprite2D

var grid_manager : GridManager = null


func _ready() -> void:
	if !active or hidden_room:
		for img in get_children():
			img.hide()
	if has_skeleton:
		skeleton_sprite.show()
	if is_starting_position:
		BoardManager.starting_position = grid_position
	password.sort()


func is_adjacent(pos : Vector2i):
	if pos in grid_manager.position_dict.keys():
		return grid_manager.position_dict[pos] in adjacencies
	else:
		return false


func try_password(cards : Array[String]):
	cards.sort()
	if cards == password:
		unlock()
	else:
		# play error noise
		pass


func unlock():
	locked_position.is_locked = false
	door_sprite.hide()
	# play door animation
