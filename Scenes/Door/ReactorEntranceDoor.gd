extends Door
class_name ReactorEntranceDoor

@export var open_delay : float = 1.0
@export var light_delay : float = 1.0
@export var lights : Array[EnvironmentLight]

func open_to_reactor():
	await get_tree().create_timer(light_delay).timeout
	for light in lights:
		light.emissive_brightness = 0.0
		light.light.hide()
	await get_tree().create_timer(open_delay).timeout
	open_door()
