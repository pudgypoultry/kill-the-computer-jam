extends Interactable

@export var highlight_mesh : MeshInstance3D

func interact():
	if can_interact:
		can_interact = false
		print("Button Pressed")
		var tween : Tween = get_tree().create_tween().bind_node(self)
		tween.tween_property(self, "position", position - Vector3.UP * 0.05, 0.1)


func highlight():
	highlight_mesh.show()


func unhighlight():
	highlight_mesh.hide()
