extends Node

signal player_control_changed(value:bool)
signal done_talking

# General game parameters
@export var board_height : float = 0.15
@export var player_move_time : float = 0.5
@export var card_insert_time : float = 1.0
@export var step_length : float = 3.0

var current_focus : Node3D
var last_focus : Node3D
var game_active : bool = false
var last_pickup_position : Vector3 = Vector3.ZERO

var player_actionable = true:
	set(value):
		player_actionable = value
		player_control_changed.emit(value)
			
var reactor_manager : ReactorManager = null
var terminal_manager : TerminalManager = null
var terminal_screen : Sprite3D = null
var fps_camera : Node3D = null
var camera_zoomed : bool = false
var original_camera_transform : Transform3D
var starting_position : Vector2i = Vector2i(-1,-1)
var main_camera : Node3D
var blank_cards : Array = []

var is_in_text_mode:bool = false

var cursor_hidden : bool = false:
	set(value):
		cursor_hidden = value
		if value:
			MouseCursor.get_global_cursor().visible = false
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		else:
			MouseCursor.get_global_cursor().visible = true
			Input.mouse_mode = Input.MOUSE_MODE_HIDDEN


func _process(_delta : float):
	if not is_in_text_mode:
		return
	
	if Input.is_action_just_pressed("interact"):
		if terminal_manager.writing:
			terminal_manager.label.visible_characters = -1
			terminal_manager.writing = false
		else:
			end_text_mode()

func _switch_screen_to_grid():
	terminal_screen.texture.viewport_path = reactor_manager.grid_subviewport.get_path()


func _switch_screen_to_terminal():
	terminal_screen.texture.viewport_path = reactor_manager.terminal_subviewport.get_path()


func switch_screen_to_menu():
	terminal_screen.texture.viewport_path = reactor_manager.menu_subviewport.get_path()


func begin_text_mode(should_zoom:bool, zoom_position : Transform3D):
	is_in_text_mode = true

	cursor_hidden = true
	
	if should_zoom:
		var tween = get_tree().create_tween().bind_node(fps_camera)
		original_camera_transform = fps_camera.global_transform
		tween.tween_property(fps_camera, "global_transform", zoom_position, BoardManager.player_move_time)
		camera_zoomed = true
		await tween.finished
		
	_switch_screen_to_terminal()

func end_text_mode():
	is_in_text_mode = false
	
	_switch_screen_to_grid()

	if camera_zoomed:
		var tween = get_tree().create_tween().bind_node(fps_camera)
		tween.tween_property(fps_camera, "global_transform", original_camera_transform, BoardManager.player_move_time)
		await tween.finished
		camera_zoomed = false
		
	cursor_hidden = false
	done_talking.emit()
