extends StaticBody3D
class_name PunchCard

@export var pickup_height : float = 0.5
@export var sprite : Sprite3D
@export var card_name : String = "PunchCard"
@export var drag_component : DragAndDropComponent

var parent_surface : Node3D
var is_slotted : bool = false
var reactor : ReactorManager = null
var original_position : Vector3 = Vector3.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	parent_surface = get_parent()


func execute() -> void:
	if reactor == null:
		reactor = BoardManager.reactor_manager
