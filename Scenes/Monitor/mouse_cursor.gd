extends CanvasLayer
class_name MouseCursor

static var _global_cursor:MouseCursor

@export var pointer_cursor:Texture2D
@export var highlight_cursor:Texture2D
@export var grab_cursor:Texture2D

@onready var mouse_position: Node2D = %MousePosition
@onready var mouse_sprite: Sprite2D = %MouseSprite

var _highlight_targets:Array[Object]
var _grab_targets:Array[Object]

static func get_global_cursor() -> MouseCursor:
	return _global_cursor

func _ready() -> void:
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

func _process(_delta: float) -> void:
	mouse_position.position = get_viewport().get_mouse_position()

func _update_mouse_cursor() -> void:
	if !_grab_targets.is_empty():
		mouse_sprite.texture = grab_cursor
	elif !_highlight_targets.is_empty():
		mouse_sprite.texture = highlight_cursor
	else:
		mouse_sprite.texture = pointer_cursor
