extends Button

@export var nextScene : String

func _ready() -> void:
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	BoardManager.main_camera.move_to_game()
