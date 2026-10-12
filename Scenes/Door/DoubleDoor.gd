extends Door

@export var first_other_door : Door
@export var second_other_door : Door
@export var time_offset : float

func open_door():
	super()
	await get_tree().create_timer(time_offset).timeout
	first_other_door.open_door()
	await get_tree().create_timer(time_offset).timeout
	second_other_door.open_door()
