extends CanvasLayer

@export var color_rect : ColorRect

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	BoardManager.fade_out_screen = self


func fade_out():
	color_rect.show()
	var tween = get_tree().create_tween()
	tween.tween_property(color_rect, "color", Color.BLACK, 3.0)
