extends StaticBody3D
class_name PunchCard

@export var pickup_height : float = 0.5
@export var sprite : Sprite3D
@export var step_length : float = 3.0
@export var drag_component : DragAndDropComponent

var parent_surface : Node3D
var is_slotted : bool = false
var character : Node3D = null
var original_position : Vector3 = Vector3.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	parent_surface = get_parent()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func execute() -> void:
	if character == null:
		character = BoardManager.reactor_character
