extends Node
class_name GridCell

@export var active : bool = true
@export var radioactivity : int = 1
@export var examine : Array[String] = ["THIS", "IS", "A", "PLACE", "OF", "HONOR"]
@export var needs_kneel : bool = false
@export var needs_grovel : bool = false

var grid_position : Vector2i = Vector2i.ZERO
var adjacencies : Array[Vector2i]

func is_adjacent(pos : Vector2i):
	return pos in adjacencies
