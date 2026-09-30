extends Node2D
class_name GridManager

@export var cell_scene : PackedScene

var cell_grid : Array[Array]
var current_position : Vector2i
var current_facing : Vector2i

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Generate 2d grid of squares
	# Turn on all positions with a 1
	# Spawn player marker at starting position, facing correct direction.
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
