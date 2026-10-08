extends StaticBody3D
class_name CardSlot

@export var start_position : Node3D
@export var insert_position : Node3D
@export var expel_position : Node3D
@export var single_mode : bool = true
@export var slot_a : bool = true
@export var audio_player : AudioStreamPlayer3D
@export var insert_sfx : AudioStreamWAV
@export var eject_sfx : AudioStreamWAV

var current_card : PunchCard = null
var original_rotation

signal card_slotted_single(action : Callable)
signal card_slotted_double(card_name : String, card_pattern : String)


func slot_card(card : PunchCard):
	if has_card():
		card.global_position = card.original_position
		return
	current_card = card
	original_rotation = card.global_rotation
	card.is_slotted = true
	BoardManager.player_actionable = false
	current_card.sort_front = false
	var tween = get_tree().create_tween().bind_node(card)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(card, "global_transform", start_position.global_transform, BoardManager.card_insert_time/4.0)
	await tween.finished
	play_sfx(insert_sfx, 0.5)
	tween = get_tree().create_tween().bind_node(card)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(card, "global_position", insert_position.global_position, BoardManager.card_insert_time)
	# wait until that's done
	await tween.finished
	current_card.visible = false
	# produce effect on screen
	if single_mode:
		if slot_a:
			card_slotted_single.emit(card.execute_a)
		else:
			card_slotted_single.emit(card.execute_b)
		await get_tree().create_timer(BoardManager.player_move_time).timeout
		eject_card()
	else:
		card_slotted_double.emit(card.light_string)
		BoardManager.player_actionable = true


func has_card() -> bool:
	return is_instance_valid(current_card)


func eject_card():
	current_card.visible = true
	current_card.is_slotted = false
	var tween = get_tree().create_tween().bind_node(current_card)
	BoardManager.player_actionable = false
	play_sfx(eject_sfx, 0.0)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(current_card, "global_position", expel_position.global_position, BoardManager.card_insert_time)
	await tween.finished
	tween = get_tree().create_tween().bind_node(current_card)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_parallel()
	tween.tween_property(current_card, "global_rotation", original_rotation, BoardManager.card_insert_time/4.0)	
	tween.tween_property(current_card, "global_position", current_card.original_position, BoardManager.card_insert_time/4.0)	
	current_card.sort_front = true
	current_card = null
	await tween.finished
	BoardManager.player_actionable = true


func play_sfx(sfx : AudioStreamWAV, await_time : float):
	audio_player.stream = sfx
	await get_tree().create_timer(await_time).timeout
	audio_player.play()
