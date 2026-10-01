extends Node3D
class_name MonitorManager

@export var switched_faceplate : Sprite3D
@export var audio_player : AudioStreamPlayer3D
@export var switch_single_sfx : AudioStreamWAV
@export var switch_double_sfx : AudioStreamWAV
@export var slots : Array[CardSlot]

var switch_flipped : bool = false
var debug_timer = 0.0
var debug_interval = 1.0


func _process(delta : float):
	if BoardManager.current_focus == self && Input.is_action_just_pressed("interact"):
		flip_switch()


func flip_switch():
	if BoardManager.player_actionable:
		if switch_flipped && check_slots() == 0:
			switch_flipped = false
			switched_faceplate.hide()
			play_sfx(switch_single_sfx)
			for slot in slots:
				slot.single_mode = true
		else:
			switch_flipped = true
			switched_faceplate.show()
			play_sfx(switch_double_sfx)
			for slot in slots:
				slot.single_mode = false


func play_sfx(sfx : AudioStreamWAV):
	audio_player.stream = sfx
	audio_player.play()


func check_slots() -> int:
	var num_cards = 0
	for slot in slots:
		if slot.current_card != null:
			num_cards += 1
	return num_cards


func _on_mouse_entered():
	if BoardManager.player_actionable:
		BoardManager.current_focus = self

func _on_mouse_exited():
	if BoardManager.current_focus == self:
		BoardManager.current_focus = null
