extends Node3D
class_name ReactorManager

@export_category("Game Rules")
@export var valid_card_combos : Dictionary = {}
@export var default_talk_message : Array[String] = [""]

@export_category("Plugging in Nodes")
@export var card_slots : Array[CardSlot]
@export var cam : Camera3D
@export var grid_manager : GridManager
@export var starting_position : Vector2i
@export var terminal_manager : TerminalManager
@export var terminal_subviewport: SubViewport
@export var grid_subviewport: SubViewport
@export var skeleton_check_ray : RayCast3D

var current_cards_scratch : Array = []
var current_position : Vector2i
var cam_tween : Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	BoardManager.reactor_manager = self
	BoardManager.fps_camera = cam
	for slot in card_slots:
		slot.card_slotted_single.connect(_handle_card_slotted_single)
		slot.card_slotted_double.connect(_handle_card_slotted_double)
	if BoardManager.starting_position != Vector2i(-1,-1):
		var real_starting_position = BoardManager.starting_position - starting_position
		cam.position.x += real_starting_position.x * BoardManager.step_length
		cam.position.z += real_starting_position.y * BoardManager.step_length
		grid_manager.current_position = BoardManager.starting_position
		current_position = BoardManager.starting_position
	else:
		grid_manager.current_position = starting_position
		current_position = starting_position


func _handle_card_slotted_single(action : Callable):
	action.call()

func _handle_card_slotted_double(_card_name : String):
	for slot in card_slots:
		if slot.has_card():
			current_cards_scratch.append(slot.current_card)
	
	if len(current_cards_scratch) == 2:
		print(current_cards_scratch)
		# check dictionary if valid combo, if not, reject both cards
		# if so, perform action
		for slot in card_slots:
			if slot.has_card():
				slot.eject_card()
		
	current_cards_scratch.clear()


func is_valid_move(forward : bool) -> bool:
	var current_direction : Vector2i = grid_manager.get_forward_direction()
	var current_cell = grid_manager.position_dict[current_position]
	if !forward:
		current_direction = -current_direction
	var target_position : Vector2i = current_position + current_direction
	print(target_position, current_direction)
	if current_cell.is_adjacent(target_position):
		var target = grid_manager.position_dict[target_position]
		if target.active && !target.is_locked && !target.has_skeleton:
			return true
	return false


func move_forward():
	BoardManager.switch_screen_to_grid()
	if is_valid_move(true):
		grid_manager.move_forward()
		cam_tween = get_tree().create_tween().bind_node(cam)
		var dir = -cam.basis.z * BoardManager.step_length
		cam_tween.tween_property(cam, "global_position", cam.global_position + dir, BoardManager.player_move_time)
		current_position = grid_manager.current_position
		print(current_position)


func move_backward():
	BoardManager.switch_screen_to_grid()
	if is_valid_move(false):
		grid_manager.move_backward()
		cam_tween = get_tree().create_tween().bind_node(cam)
		var dir = cam.basis.z * BoardManager.step_length
		cam_tween.tween_property(cam, "global_position", cam.global_position + dir, BoardManager.player_move_time)
		current_position = grid_manager.current_position


func turn(dir : String):
	BoardManager.switch_screen_to_grid()
	grid_manager.turn(dir)
	cam_tween = get_tree().create_tween().bind_node(cam)
	match dir:
		"left":
			cam_tween.tween_property(cam, "rotation:y", cam.rotation.y + deg_to_rad(90.0), BoardManager.player_move_time)
		"right":
			cam_tween.tween_property(cam, "rotation:y", cam.rotation.y + deg_to_rad(-90.0), BoardManager.player_move_time)


func zoom_in():
	BoardManager.switch_screen_to_grid()
	grid_manager.zoom_in()


func zoom_out():
	BoardManager.switch_screen_to_grid()
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


func talk():
	var current_direction : Vector2i = Vector2i.ZERO
	current_direction = grid_manager.get_forward_direction()
	var target_position : Vector2i = current_position + current_direction
	if grid_manager.position_dict[target_position].has_skeleton:
		if skeleton_check_ray.is_colliding():
			var skeleton = skeleton_check_ray.get_collider()
			print_to_terminal(skeleton.talk_message)
			BoardManager.talking_zoom_in(skeleton.zoom_position)
	else:
		print_to_terminal(default_talk_message)


func read_scripture(type : String):
	var verse : Array[String] = [""]
	match type:
		"scary":
			verse = [Scripture.random_scary()]
		"hopeful":
			verse = [Scripture.random_hopeful()]
	BoardManager.switch_screen_to_terminal()
	print_to_terminal(verse)
