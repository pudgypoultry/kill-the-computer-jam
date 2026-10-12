extends Node
class_name TitleScreenTransitionManager

@export var target : SubViewport
@export var menu_root : Control
@export var cursor : Sprite2D
@export var start_button : Button
@export var sensitivity : float = 0.25
@export var mouse_offset : Vector2 = Vector2.ZERO

var active : bool = false
var pos : Vector2 = Vector2.ZERO
var button_mask : int = 0


func _ready() -> void:
	start_button.pressed.connect(set_active.bind(false))
	await get_tree().process_frame
	pos = menu_root.get_global_rect().get_center()
	target.notification(NOTIFICATION_VP_MOUSE_ENTER)
	set_active(true)


func set_active(value: bool) -> void:
	active = value
	cursor.visible = value
	BoardManager.cursor_hidden = value
	if value:
		_move_cursor(Vector2.ZERO)


func _input(event: InputEvent) -> void:
	if not active:
		return

	if event is InputEventMouseMotion:
		_move_cursor(event.relative * sensitivity)
	elif event is InputEventMouseButton:
		button_mask = event.button_mask
		var ev := InputEventMouseButton.new()
		ev.button_index = event.button_index
		ev.pressed = event.pressed
		ev.double_click = event.double_click
		ev.button_mask = event.button_mask
		ev.position = pos
		ev.global_position = pos
		target.push_input(ev, true)
	else:
		return

	get_viewport().set_input_as_handled()


func _move_cursor(delta: Vector2) -> void:
	var rect := menu_root.get_global_rect()
	var old := pos
	pos = (pos + delta).clamp(rect.position, rect.end - Vector2.ONE)
	cursor.position = pos + mouse_offset

	var ev := InputEventMouseMotion.new()
	ev.position = pos
	ev.global_position = pos
	ev.relative = pos - old
	ev.button_mask = button_mask
	target.push_input(ev, true)
