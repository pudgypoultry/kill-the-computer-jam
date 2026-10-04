extends HBoxContainer

@export var minus_button : Button
@export var plus_button : Button
@export var progress_bar : ProgressBar
@export var audio_bus_name : String = ""


func _ready() -> void:
	minus_button.pressed.connect(minus)
	plus_button.pressed.connect(plus)


func minus():
	if progress_bar.value < 100:
		progress_bar.value -= 5
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index(audio_bus_name), linear_to_db(progress_bar.value))


func plus():
	if progress_bar.value < 100:
		progress_bar.value += 5
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index(audio_bus_name), linear_to_db(progress_bar.value))
