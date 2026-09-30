extends PunchCard

func execute() -> void:
	super()
	print("Rotating Left")
	var tween = get_tree().create_tween().bind_node(character)
	tween.tween_property(character, "rotation:y", character.rotation.y + deg_to_rad(90.0), 1.0)
	grid.turn("left")
