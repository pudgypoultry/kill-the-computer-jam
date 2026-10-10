extends Node3D
class_name Door

@export var can_slam : bool = false

@onready var door_open_player: AudioStreamPlayer3D = %DoorOpenPlayer

@export var indicator : GridIndicator
@export var door_holder : Node3D
@export var door_entry_sound : AudioStreamWAV
@export var door_success_sound : AudioStreamWAV
@export var door_failure_sound : AudioStreamWAV
@onready var door_speaker_player: AudioStreamPlayer3D = %DoorSpeakerPlayer

var tween : Tween

var is_open:bool = false
var has_slammed:bool = false
var original_position : Vector3

func open_door():
	is_open = true
	original_position = door_holder.position
	indicator.indicator_state = GridIndicator.IndicatorState.CORRECT
	door_speaker_player.stream = door_success_sound
	door_speaker_player.play()
	await get_tree().create_timer(1.0).timeout
	door_open_player.play()
	await get_tree().create_timer(1.0).timeout
	tween = get_tree().create_tween().bind_node(door_holder)
	tween.tween_property(door_holder, "position", position - transform.basis.z * 0.125, 0.5)
	tween.tween_interval(0.25)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(door_holder, "position", position - transform.basis.x * 3.0, 1.0)


func close_door():
	if !has_slammed:
		is_open = false
		has_slammed = true
		door_holder.position = original_position



func wrong_password():
	if is_open:
		return
		
	await get_tree().create_timer(1.0).timeout
	door_speaker_player.stream = door_failure_sound
	door_speaker_player.play()
	indicator.indicator_state = GridIndicator.IndicatorState.INCORRECT
	await get_tree().create_timer(1.0).timeout
	indicator.indicator_state = GridIndicator.IndicatorState.IDLE
	wipe_indicator()

func cancel_in_progress() -> void:
	if not is_open and indicator.indicator_state == GridIndicator.IndicatorState.INPUT:
		wrong_password()

func wipe_indicator():
	indicator.indicator_state = GridIndicator.IndicatorState.IDLE
	indicator.set_light_pattern("ooooo ooooo ooooo ooooo ooooo")

func input_string(card_string : String) -> void:
	if indicator.indicator_state == GridIndicator.IndicatorState.INPUT:
		_add_to_indicator(card_string)
	else:
		_set_indicator(card_string)
	
	door_speaker_player.stream = door_entry_sound
	door_speaker_player.play()
	indicator.indicator_state = GridIndicator.IndicatorState.INPUT

func _set_indicator(card_string : String):
	indicator.set_light_pattern(card_string)

func _add_to_indicator(card_string : String):
	var current_pattern = indicator.current_pattern
	for i in len(card_string):
		if card_string[i] == "x":
			current_pattern[i] = "x"
	indicator.set_light_pattern(current_pattern)
