extends Node3D
class_name ReactorManager

@export_category("Game Rules")
@export var valid_card_combos : Dictionary = {}

@export_category("Plugging in Nodes")
@export var card_slots : Array[CardSlot]
@export var cam : Camera3D
@export var grid_manager : GridManager
@export var starting_position : Vector2i
@export var terminal_manager : TerminalManager
@export var terminal_subviewport: SubViewport
@export var grid_subviewport: SubViewport

var current_cards : Array = []
var current_position : Vector2i
var cam_tween : Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	BoardManager.reactor_manager = self
	for slot in card_slots:
		slot.card_slotted_single.connect(_handle_card_slotted_single)
		slot.card_slotted_double.connect(_handle_card_slotted_double)
	grid_manager.current_position = starting_position
	current_position = starting_position


func _handle_card_slotted_single(action : Callable):
	action.call()


func _handle_card_slotted_double(card_name : String):
	if len(current_cards) == 1:
		current_cards.append(card_name)
		print(current_cards)
		# check dictionary if valid combo, if not, reject both cards
		# if so, perform action
		current_cards.clear()
		for slot in card_slots:
			slot.eject_card()
	else:
		current_cards.append(card_name)
		print(current_cards)


func is_valid_move(forward : bool) -> bool:
	var current_direction : Vector2i = grid_manager.get_forward_direction()
	var current_cell = grid_manager.position_dict[current_position]
	if !forward:
		current_direction = -current_direction
	var target_position : Vector2i = current_position + current_direction
	print(target_position, current_direction)
	if current_cell.is_adjacent(target_position):
		if grid_manager.position_dict[target_position].active:
			return true
	return false


func move_forward():
	if is_valid_move(true):
		grid_manager.move_forward()
		cam_tween = get_tree().create_tween().bind_node(cam)
		var dir = -cam.basis.z * BoardManager.step_length
		cam_tween.tween_property(cam, "global_position", cam.global_position + dir, BoardManager.player_move_time)
		current_position = grid_manager.current_position
		print(current_position)


func move_backward():
	if is_valid_move(false):
		grid_manager.move_backward()
		cam_tween = get_tree().create_tween().bind_node(cam)
		var dir = cam.basis.z * BoardManager.step_length
		cam_tween.tween_property(cam, "global_position", cam.global_position + dir, BoardManager.player_move_time)
		current_position = grid_manager.current_position


func turn(dir : String):
	grid_manager.turn(dir)
	cam_tween = get_tree().create_tween().bind_node(cam)
	match dir:
		"left":
			cam_tween.tween_property(cam, "rotation:y", cam.rotation.y + deg_to_rad(90.0), BoardManager.player_move_time)
		"right":
			cam_tween.tween_property(cam, "rotation:y", cam.rotation.y + deg_to_rad(-90.0), BoardManager.player_move_time)


func zoom_in():
	grid_manager.zoom_in()


func zoom_out():
	grid_manager.zoom_out()


func print_to_terminal(new_message : Array[String]) -> void:
	terminal_manager.new_message(new_message)


func examine():
	var current_cell = grid_manager.position_dict[current_position]
	var current_direction : Vector2i = Vector2i.ZERO
	if is_valid_move(true):
		current_direction = grid_manager.get_forward_direction()
		var target_position : Vector2i = current_position + current_direction
		var examine_cell = grid_manager.position_dict[target_position]
		print_to_terminal(examine_cell.examine)
	else:
		print_to_terminal(current_cell.examine)
