extends Node

@export var board_height : float = 0.15

var current_focus : Node3D
var last_focus : Node3D
var game_active : bool = false
var last_pickup_position : Vector3 = Vector3.ZERO
var player_actionable = true
var reactor_character : Node3D = null
