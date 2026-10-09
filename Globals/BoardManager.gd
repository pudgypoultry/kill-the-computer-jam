extends Node

# General game parameters
@export var board_height : float = 0.15
@export var player_move_time : float = 0.5
@export var card_insert_time : float = 1.0
@export var step_length : float = 3.0

var current_focus : Node3D
var last_focus : Node3D
var game_active : bool = false
var last_pickup_position : Vector3 = Vector3.ZERO
var player_actionable = true
var reactor_manager : ReactorManager = null
var terminal_screen : Sprite3D = null
var fps_camera : Node3D = null
var camera_zoomed : bool = false
var original_camera_position : Vector3 = Vector3.ZERO
var global_cursor : MouseCursor = null
var starting_position : Vector2i = Vector2i(-1,-1)
var main_camera : Node3D
var blank_cards : Array = []

var cursor_hidden : bool = false:
	set(value):
		cursor_hidden = value
		if value:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		else:
			Input.mouse_mode = Input.MOUSE_MODE_HIDDEN


var last_mouse_position : Vector2 = Vector2.ZERO


func _process(_delta : float):
	if player_actionable:
		if Input.is_action_just_pressed("interact") && camera_zoomed:
			talking_zoom_out()


func switch_screen_to_grid():
	terminal_screen.texture.viewport_path = reactor_manager.grid_subviewport.get_path()


func switch_screen_to_terminal():
	terminal_screen.texture.viewport_path = reactor_manager.terminal_subviewport.get_path()


func switch_screen_to_menu():
	terminal_screen.texture.viewport_path = reactor_manager.menu_subviewport.get_path()


func talking_zoom_in(zoom_position : Vector3):
	if global_cursor == null:
		global_cursor = MouseCursor._global_cursor
	global_cursor.hide()
	var tween = get_tree().create_tween().bind_node(fps_camera)
	original_camera_position = fps_camera.global_position
	tween.tween_property(fps_camera, "global_position", zoom_position, BoardManager.player_move_time)
	camera_zoomed = true
	cursor_hidden = true
	last_mouse_position = get_viewport().get_mouse_position()
	await tween.finished
	switch_screen_to_terminal()


func talking_zoom_out():
	if camera_zoomed:
		global_cursor.show()
		switch_screen_to_grid()
		var tween = get_tree().create_tween().bind_node(fps_camera)
		tween.tween_property(fps_camera, "global_position", original_camera_position, BoardManager.player_move_time)
		camera_zoomed = false
		cursor_hidden = false
		await tween.finished
