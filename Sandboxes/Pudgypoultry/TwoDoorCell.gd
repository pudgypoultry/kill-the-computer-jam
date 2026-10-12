extends GridCell

@export var other_door_sprite : Sprite2D
@export var other_locked_position : GridCell


func unlock():
	super()
	other_locked_position.is_locked = false
	other_door_sprite.hide()
