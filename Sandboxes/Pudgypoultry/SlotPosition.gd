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
signal card_slotted_double(card_name : String)


func slot_card(card : PunchCard):
	# move card to position slowly
	current_card = card
	original_rotation = card.global_rotation
	card.global_position = start_position.global_position
	card.global_rotation = global_rotation
	card.is_slotted = true
	BoardManager.player_actionable = false
	play_sfx(insert_sfx, 0.5)
	var tween = get_tree().create_tween().bind_node(card)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(card, "global_position", insert_position.global_position, BoardManager.card_insert_time)
	# wait until that's done
	await tween.finished
	# produce effect on screen
	if single_mode:
		if slot_a:
			card_slotted_single.emit(card.execute_a)
		else:
			card_slotted_single.emit(card.execute_b)
		await get_tree().create_timer(BoardManager.player_move_time).timeout
		eject_card()
	else:
		card_slotted_double.emit(card.card_name)
		BoardManager.player_actionable = true


func eject_card():
	current_card.is_slotted = false
	var tween = get_tree().create_tween().bind_node(current_card)
	BoardManager.player_actionable = false
	play_sfx(eject_sfx, 0.0)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(current_card, "global_position", expel_position.global_position, BoardManager.card_insert_time)
	await tween.finished
	current_card.global_position = current_card.original_position
	current_card.global_rotation = original_rotation
	current_card = null
	BoardManager.player_actionable = true


func play_sfx(sfx : AudioStreamWAV, await_time : float):
	audio_player.stream = sfx
	await get_tree().create_timer(await_time).timeout
	audio_player.play()
