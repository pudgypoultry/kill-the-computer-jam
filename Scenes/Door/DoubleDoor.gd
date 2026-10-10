extends Door

@export var other_door : Door
@export var time_offset : float

func open_door():
	super()
	await get_tree().create_timer(time_offset).timeout
	other_door.open_door()
