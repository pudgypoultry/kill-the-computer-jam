extends Node3D
class_name ReactorManager

@export var card_slots : Array[CardSlot]
@export var cam : Camera3D
@export var grid_manager : GridManager

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for slot in card_slots:
		slot.card_slotted.connect(_handle_card_slotted)
	BoardManager.reactor_character = cam


func _handle_card_slotted(action : Callable):
	action.call()
