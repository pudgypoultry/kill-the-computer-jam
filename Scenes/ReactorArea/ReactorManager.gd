extends Node3D
class_name ReactorManager

@export var card_slots : Array[CardSlot]
@export var cam : Camera3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for slot in card_slots:
		slot.card_slotted.connect(_handle_card_slotted)
	BoardManager.reactor_character = cam


func _handle_card_slotted(action : Callable):
	action.call()


func move_forward():
	var tween = get_tree().create_tween().bind_node(cam)
	tween.tween_property(cam, "position", cam.position.z - 1, 1.0)
