extends Door
class_name ReactorEntranceDoor

@export var open_delay : float = 1.0
@export var light_delay : float = 1.0
@export var lights : Array[EnvironmentLight]

@export var light_shut_off_sound:AudioStreamWAV

var has_opened:bool = false

func open_to_reactor():
	if has_opened:
		return
	has_opened = true
	await get_tree().create_timer(light_delay).timeout
	if is_instance_valid(light_shut_off_sound):
		door_speaker_player.stream = light_shut_off_sound
		door_speaker_player.play()
	for light in lights:
		light.emissive_brightness = 0.0
		light.light.hide()
	await get_tree().create_timer(open_delay).timeout
	open_door()
