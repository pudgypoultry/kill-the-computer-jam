extends Node3D
class_name Door

@onready var door_audio_player: AudioStreamPlayer3D = %DoorAudioPlayer

@export var indicator : GridIndicator
@export var north_south : bool = false

var tween : Tween

func open_door():
	indicator.correct_password()
	await get_tree().create_timer(1.0).timeout
	door_audio_player.play()
	tween = get_tree().create_tween().bind_node(self)
	if north_south:
		tween.tween_property(self, "position:z", position.x - 0.125, 0.5)
		tween.tween_interval(0.25)
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.set_ease(Tween.EASE_IN)
		tween.tween_property(self, "position:x", position.z - 3.0, 1.0)
	else:
		tween.tween_property(self, "position:z", position.z - 0.125, 0.5)
		tween.tween_interval(0.25)
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.set_ease(Tween.EASE_IN)
		tween.tween_property(self, "position:x", position.x - 3.0, 1.0)


func wrong_password():
	indicator.is_blinking = true
	await get_tree().create_timer(1.0).timeout
	indicator.is_blinking = false
	wipe_indicator()


func wipe_indicator():
	indicator.set_light_pattern("ooooo ooooo ooooo ooooo ooooo")


func set_indicator(card_string : String):
	indicator.set_light_pattern(card_string)


func add_to_indicator(card_string : String):
	var current_pattern = indicator.current_pattern
	for i in len(card_string):
		if card_string[i] == "x":
			current_pattern[i] = "x"
	indicator.set_light_pattern(current_pattern)
