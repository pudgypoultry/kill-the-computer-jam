extends Button

@export var scene_to_show : Control
@export var scene_to_hide : Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pressed.connect(_on_pressed)


func _on_pressed():
	scene_to_show.show()
	scene_to_hide.hide()
