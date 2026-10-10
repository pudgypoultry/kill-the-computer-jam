@tool

extends GridCell

@export var second_door_sprite : Sprite2D
@export var second_locked_position : GridCell


func unlock():
	locked_position.is_locked = false
	second_locked_position.is_locked = false
	door_sprite.hide()
	second_door_sprite.hide()
