extends Node3D
class_name Door

@export var can_slam : bool = false
@export var starts_open:bool = false

@export var indicator : GridIndicator
@export var door_holder : Node3D
@export var door_entry_sound : AudioStreamWAV
@export var door_success_sound : AudioStreamWAV
@export var door_failure_sound : AudioStreamWAV
@export var door_slam_sound : AudioStreamWAV

@onready var door_speaker_player: AudioStreamPlayer3D = %DoorSpeakerPlayer
@onready var door_open_player: AudioStreamPlayer3D = %DoorOpenPlayer

var tween : Tween

var is_open:bool = false
var has_slammed:bool = false
var original_position : Vector3

func _ready() -> void:
	if starts_open:
		original_position = door_holder.position
		door_holder.position -= transform.basis.x * 3.0
		is_open = true

func _play_accept_effect() -> void:
	if is_instance_valid(indicator):
		indicator.indicator_state = GridIndicator.IndicatorState.CORRECT
		door_speaker_player.stream = door_success_sound
		door_speaker_player.play()
		await get_tree().create_timer(1.0).timeout

func open_door():
	is_open = true
	original_position = door_holder.position
	await _play_accept_effect()
	door_open_player.play()
	tween = get_tree().create_tween().bind_node(door_holder)
	tween.tween_property(door_holder, "global_position", global_position - door_holder.global_transform.basis.z * 0.125, 0.5)
	tween.tween_interval(0.25)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(door_holder, "global_position", global_position - door_holder.global_transform.basis.x * 3.0 - door_holder.global_transform.basis.z * 0.125, 1.0)

func close_door():
	if !has_slammed:
		is_open = false
		has_slammed = true
		tween = get_tree().create_tween().bind_node(door_holder)
		tween.tween_property(door_holder, "position", original_position, 0.5)
		#door_holder.position = original_position
		if is_instance_valid(door_slam_sound):
			door_open_player.stream = door_slam_sound
			door_open_player.play()

func wrong_password():
	if is_open or not is_instance_valid(indicator):
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
