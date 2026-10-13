extends Node

signal make_switch_go_off_now
signal player_control_changed(value:bool)
signal done_talking
signal monitor_off

# General game parameters
@export var board_height : float = 0.15
@export var player_move_time : float = 0.5
@export var card_insert_time : float = 1.0
@export var step_length : float = 3.0

var current_focus : Node3D
var last_focus : Node3D
var game_active : bool = false
var last_pickup_position : Vector3 = Vector3.ZERO

var _player_actionable_blockers:Array[Node]

var player_actionable:
	get():
		#player_actionable = value
		#player_control_changed.emit(value)
		return _player_actionable_blockers.is_empty()
			
var reactor_manager : ReactorManager = null
var terminal_manager : TerminalManager = null
var terminal_screen : Sprite3D = null
var fps_camera : Node3D = null
var camera_zoomed : bool = false
var original_camera_transform : Transform3D
var starting_position : Vector2i = Vector2i(-1,-1)
var main_camera : Node3D
var blank_cards : Array = []
var explosion_light : OmniLight3D
var fade_out_screen : CanvasLayer
var exclusive_text_mode:bool = false

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
	#if Input.is_action_just_pressed("pause") && player_actionable:
		#main_camera.move_to_menu()
		#await get_tree().create_timer(0.5).timeout
		#switch_screen_to_menu()

	
	if not exclusive_text_mode or _starting_text_mode:
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

var _text_blocker:Node

func begin_background_text_display() -> void:
	_switch_screen_to_terminal()

func end_background_text_display() -> void:
	_switch_screen_to_grid()

var _starting_text_mode:bool = false
func begin_text_mode(should_zoom:bool, zoom_position : Transform3D):
	if exclusive_text_mode or _starting_text_mode:
		push_error("Text mode entered recursively. This is unsupported and very bad things are likely to happen.")
		return
		
	_starting_text_mode = true
		
	exclusive_text_mode = true
	_text_blocker = add_player_actionable_blocker(self)
	cursor_hidden = true
	
	if should_zoom:
		var tween = get_tree().create_tween().bind_node(fps_camera)
		original_camera_transform = fps_camera.global_transform
		tween.tween_property(fps_camera, "global_transform", zoom_position, BoardManager.player_move_time)
		camera_zoomed = true
		await tween.finished
		
	_starting_text_mode = false
	_switch_screen_to_terminal()

func end_text_mode():
	if _starting_text_mode:
		return
	
	exclusive_text_mode = false
	
	_switch_screen_to_grid()

	if camera_zoomed:
		var tween = get_tree().create_tween().bind_node(fps_camera)
		tween.tween_property(fps_camera, "global_transform", original_camera_transform, BoardManager.player_move_time)
		await tween.finished
		camera_zoomed = false
		
	cursor_hidden = false
	done_talking.emit()
	
	# CW: hack to avoid a mouse click that ends text mode also being eaten by a card or the faceplate switch unintentionally
	await get_tree().process_frame
	remove_player_actionable_blocker(_text_blocker)	
	_text_blocker = null

func add_player_actionable_blocker(to_parent:Node) -> Node:
	var new_blocker = Node.new()
	to_parent.add_child(new_blocker)
	var blocking_changed:bool = _player_actionable_blockers.is_empty()
	_player_actionable_blockers.push_back(new_blocker)
	
	if blocking_changed:
		player_control_changed.emit(false)
	
	return new_blocker
		
func remove_player_actionable_blocker(blocker:Node) -> void:
	if _player_actionable_blockers.has(blocker):
		var blocker_parent = blocker.get_parent()
		if is_instance_valid(blocker_parent):
			blocker_parent.remove_child(blocker)
		_player_actionable_blockers.erase(blocker)		
		blocker.queue_free()
		
		if _player_actionable_blockers.is_empty():
			player_control_changed.emit(true)

func make_switch_go_off() -> void:
	make_switch_go_off_now.emit()

func kill_monitor() -> void:
	monitor_off.emit()

# CW: this is here because it's easy to find hahaha
func get_explosion_bus_vol() -> float:
	var explosion_idx = AudioServer.get_bus_index("ExplosionFX")
	var analyzer:AudioEffectSpectrumAnalyzerInstance = AudioServer.get_bus_effect_instance(explosion_idx, 0) as AudioEffectSpectrumAnalyzerInstance
	var val = analyzer.get_magnitude_for_frequency_range(0, 10000).length()
	return val
