extends StaticBody3D
class_name PunchCard

@export var pickup_height : float = 0.5
@export var sprite : Sprite3D

var parent_surface : Node3D
var is_slotted : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	parent_surface = get_parent()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func execute() -> void:
	print(name, " has not overridden execute correctly!")
