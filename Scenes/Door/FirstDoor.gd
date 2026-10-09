extends Door

@export var other_door : Node3D

func open_door():
	super()
	other_door.hide()
