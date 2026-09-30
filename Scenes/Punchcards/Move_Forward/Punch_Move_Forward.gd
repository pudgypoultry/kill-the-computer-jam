extends PunchCard

func execute() -> void:
	super()
	print_debug("Moving Forward")
	var tween = get_tree().create_tween().bind_node(character)
	tween.tween_property(character, "global_position", character.global_position - character.basis.z * step_length, 1.0)
	grid.move_forward()
