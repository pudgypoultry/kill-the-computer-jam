extends Sprite2D
class_name TinyMapImage

func _ready() -> void:
	hide()
	while not BoardManager.reactor_manager:
		await get_tree().process_frame
	BoardManager.reactor_manager.grid_manager.zoom_change.connect(_on_zoom_change)
	
func _on_zoom_change(zoom_level:int) -> void:
	if zoom_level >= 1:
		show()
	else:
		hide()
