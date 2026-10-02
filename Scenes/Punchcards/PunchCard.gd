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

# CW: This is sort of a hack. Putting the card sprite too far in front of the faceplate creates
# parallax issues with grabbing and dropping, but putting it too close creates alpha sorting issues
# with the outline, causing part of the outline shader to be trimmed.
# Being able to switch whether to force sorting in front (mildly) fixes both these issues, even if
# it's a bit hacky.
var sort_front:bool = true:
	set(value):
		sort_front = value
		if is_instance_valid(sprite):
			sprite.sorting_offset = 20.0 if value else 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	parent_surface = get_parent()
	sort_front = true


func execute() -> void:
	if reactor == null:
		reactor = BoardManager.reactor_manager


func execute_a() -> void:
	if reactor == null:
		reactor = BoardManager.reactor_manager


func execute_b() -> void:
	if reactor == null:
		reactor = BoardManager.reactor_manager
