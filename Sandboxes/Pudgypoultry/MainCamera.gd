extends Camera3D

@export var game_position : Node3D
@export var menu_position : Node3D

var tween : Tween

func move_to_game():
	tween = get_tree().create_tween().bind_node(self)
	tween.tween_property(self, "global_position", game_position.global_position, 0.5)


func move_to_menu():
	tween = get_tree().create_tween().bind_node(self)
	tween.tween_property(self, "global_position", menu_position.global_position, 0.5)
