extends Interactable

@export var highlight_mesh : MeshInstance3D
@export var slot : CardSlot

var can_press : bool = false


func _process(delta : float) -> void:
	if can_press && Input.is_action_just_pressed("pick_up"):
		interact()


func interact():
	can_interact = false
	slot.eject_card()
	print("Button Pressed")


func highlight():
	highlight_mesh.show()


func unhighlight():
	highlight_mesh.hide()


func _focus():
	can_press = true
	highlight()

func _unfocus():
	can_press = false
	unhighlight()
