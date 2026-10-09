extends CanvasLayer
class_name MouseCursor

static var _global_cursor:MouseCursor

@export var pointer_cursor:Texture2D
@export var highlight_cursor:Texture2D
@export var grab_cursor:Texture2D

@onready var mouse_position: Node2D = %MousePosition
@onready var mouse_sprite: Sprite2D = %MouseSprite

@onready var mouse_grab_player: AudioStreamPlayer = %MouseGrabPlayer
@onready var mouse_hover_player: AudioStreamPlayer = %MouseHoverPlayer

const _hover_machine_gun_delay:float = 0.25

enum MouseState {
	NORMAL,
	HOVER,
	GRAB
}

var _mouse_state:MouseState:
	set(value):
		_transition_mouse_state(_mouse_state, value)
		_mouse_state = value
		
var _highlight_targets:Array[Object]
var _grab_targets:Array[Object]
var _hover_machine_gun_timer:Timer

static func get_global_cursor() -> MouseCursor:
	return _global_cursor

func _ready() -> void:
	_hover_machine_gun_timer = Timer.new()
	_hover_machine_gun_timer.ignore_time_scale = true
	_hover_machine_gun_timer.one_shot = true
	add_child(_hover_machine_gun_timer)
	
	_global_cursor = self
	
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	_update_mouse_cursor()

func add_highlight_target(target:Object) -> void:
	if _highlight_targets.has(target):
		push_error("Double add of highlight target.")
		return
		
	_highlight_targets.push_back(target)
	_update_mouse_cursor()

func add_grab_target(target:Object) -> void:
	if _grab_targets.has(target):
		push_error("Double add of grab target.")
		return
		
	_grab_targets.push_back(target)
	_update_mouse_cursor()

func remove_highlight_target(target:Object) -> void:
	if not _highlight_targets.has(target):
		push_error("Attempted remove of highlight target, but it does not exist")
		return
		
	_highlight_targets.erase(target)
	_update_mouse_cursor()

func remove_grab_target(target:Object) -> void:
	if not _grab_targets.has(target):
		push_error("Attempted remove of grab target, but it does not exist")
		return
		
	_grab_targets.erase(target)
	_update_mouse_cursor()

func has_highlight_target(target:Object) -> bool:
	return _highlight_targets.has(target)

func has_grab_target(target:Object) -> bool:
	return _grab_targets.has(target)

func is_highlighting() -> bool:
	return !_highlight_targets.is_empty()

func is_grabbing() -> bool:
	return !_grab_targets.is_empty()

func _process(_delta: float) -> void:
	mouse_position.position = get_viewport().get_mouse_position()

func _update_mouse_cursor() -> void:
	if !_grab_targets.is_empty():
		_mouse_state = MouseState.GRAB
	elif !_highlight_targets.is_empty():
		_mouse_state = MouseState.HOVER
	else:
		_mouse_state = MouseState.NORMAL

func _transition_mouse_state(old_state:MouseState, new_state:MouseState) -> void:
	if old_state == new_state:
		return
		
	match new_state:
		MouseState.NORMAL:
			mouse_sprite.texture = pointer_cursor
		MouseState.HOVER:
			mouse_sprite.texture = highlight_cursor
		MouseState.GRAB:
			mouse_sprite.texture = grab_cursor
	
	if old_state == MouseState.NORMAL and new_state == MouseState.HOVER:
		if not _hover_machine_gun_timer.is_stopped():
			return
			
		mouse_hover_player.play()
		
		_hover_machine_gun_timer.start(_hover_machine_gun_delay)
	elif new_state == MouseState.GRAB:
		mouse_grab_player.play()
