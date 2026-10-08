extends Node3D
class_name Door

@export var indicator : GridIndicator

var tween : Tween

func open_door():
	indicator.correct_password()
	await get_tree().create_timer(1.0).timeout
	tween = get_tree().create_tween().bind_node(self)
	tween.tween_property(self, "position:y", position.y + 3.0, 0.5)


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
