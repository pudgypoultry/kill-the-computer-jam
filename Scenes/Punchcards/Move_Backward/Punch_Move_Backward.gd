extends PunchCard

func execute() -> void:
	super()
	print_debug("Moving Backward")
	reactor.move_backward()
	#var tween = get_tree().create_tween().bind_node(character)
	#tween.tween_property(character, "global_position", character.global_position - character.basis.z * step_length, BoardManager.player_move_time)
