extends Node3D
class_name Door

var tween : Tween

func open_door():
	tween = get_tree().create_tween().bind_node(self)
	tween.tween_property(self, "position:y", position.y + 3.0, 0.5)
