extends Door

@export var other_door_to_open : Door
@export var time_offset : float

func open_door():
	super()
	await get_tree().create_timer(time_offset).timeout
	other_door_to_open.open_door()
