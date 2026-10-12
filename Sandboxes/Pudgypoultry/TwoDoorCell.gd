extends GridCell

@export var second_door_sprite : Sprite2D
@export var second_locked_position : GridCell
@export var third_door_sprite : Sprite2D
@export var third_locked_position : GridCell


func unlock():
	super()
	second_locked_position.is_locked = false
	third_locked_position.is_locked = false
	second_door_sprite.hide()
	third_door_sprite.hide()
