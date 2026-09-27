extends StaticBody3D
class_name CardSlot

@export var start_position : Node3D
@export var insert_position : Node3D
@export var expel_position : Node3D

var current_card : PunchCard

signal card_slotted(action : Callable)

func slot_card(card : PunchCard):
	# move card to position slowly
	current_card = card
	card.global_position = start_position.global_position
	card.is_slotted = true
	BoardManager.player_actionable = false
	var tween = get_tree().create_tween().bind_node(card)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(card, "global_position", insert_position.global_position, 1.0)
	# wait until that's done
	await tween.finished
	BoardManager.player_actionable = true
	# produce effect on screen
	card_slotted.emit(card.execute)


func eject_card():
	current_card.is_slotted = false
	var tween = get_tree().create_tween().bind_node(current_card)
	BoardManager.player_actionable = false
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(current_card, "global_position", expel_position.global_position, 1.0)
	await tween.finished
	BoardManager.player_actionable = true
