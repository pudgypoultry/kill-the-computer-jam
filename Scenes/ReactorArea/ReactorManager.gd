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
@export var menu_subviewport: SubViewport
@export var skeleton_check_ray : RayCast3D
@export var door_check_ray : RayCast3D
@export var footstep_player : AudioStreamPlayer3D

@export var footstep_sfx : Array[AudioStreamWAV]
@export var turn_sfx : Array[AudioStreamWAV]
@export var bonk_sfx : AudioStreamWAV

var _current_cards_scratch : Array = []
var current_position : Vector2i
var cam_tween : Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	BoardManager.reactor_manager = self
	BoardManager.fps_camera = cam
	for slot in card_slots:
		slot.card_slotted_single.connect(_handle_card_slotted_single)
		slot.card_slotted_double.connect(_handle_card_slotted_double)
		slot.card_ejected.connect(_handle_card_ejected)
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

func _handle_card_ejected() -> void:
	var current_cell = grid_manager.position_dict[current_position]
	if current_cell.has_password:
		var door : Door = door_check_ray.get_collider()
		if not is_instance_valid(door):
			push_error("Collided with a non-door or nothing in door ray check!")
			return
		door.cancel_in_progress()
	

func _handle_card_slotted_double(card_pattern : String):
	var current_cell = grid_manager.position_dict[current_position]
	for slot in card_slots:
		if slot.has_card():
			_current_cards_scratch.append(slot.current_card.card_name)
			
	if current_cell.has_password:
		var door : Door = door_check_ray.get_collider()
		if not is_instance_valid(door):
			push_error("Collided with a non-door or nothing in door ray check!")
			_current_cards_scratch.clear()
			return
			
		door.input_string(card_pattern)
		
		# two cards! Try the door
		if len(_current_cards_scratch) == 2:
			_current_cards_scratch.sort()
			if _current_cards_scratch == current_cell.password:
				current_cell.unlock()
				door.open_door()
			else:
				door.wrong_password()
			for slot in card_slots:
				if slot.has_card():
					slot.eject_card()
		
	_current_cards_scratch.clear()


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
		play_footsteps()
	else:
		cam_tween = get_tree().create_tween().bind_node(cam)
		var dir = -cam.basis.z * BoardManager.step_length
		var cur_cam_position := cam.global_position
		cam_tween.set_ease(Tween.EASE_IN)
		cam_tween.set_trans(Tween.TRANS_CUBIC)
		cam_tween.tween_property(cam, "global_position", cam.global_position + dir * 0.25, BoardManager.player_move_time * 0.5)
		await cam_tween.finished
		play_error_bonk()
		cam_tween = get_tree().create_tween().bind_node(cam)
		cam_tween.tween_property(cam, "global_position", cur_cam_position, BoardManager.player_move_time * 0.5)


func move_backward():
	BoardManager.switch_screen_to_grid()
	if is_valid_move(false):
		grid_manager.move_backward()
		cam_tween = get_tree().create_tween().bind_node(cam)
		var dir = cam.basis.z * BoardManager.step_length
		cam_tween.tween_property(cam, "global_position", cam.global_position + dir, BoardManager.player_move_time)
		play_footsteps()
		current_position = grid_manager.current_position
	else:
		cam_tween = get_tree().create_tween().bind_node(cam)
		var dir = cam.basis.z * BoardManager.step_length
		var cur_cam_position := cam.global_position
		cam_tween.set_ease(Tween.EASE_IN)
		cam_tween.set_trans(Tween.TRANS_CUBIC)
		cam_tween.tween_property(cam, "global_position", cam.global_position + dir * 0.25, BoardManager.player_move_time * 0.5)
		await cam_tween.finished
		play_error_bonk()
		cam_tween = get_tree().create_tween().bind_node(cam)
		cam_tween.tween_property(cam, "global_position", cur_cam_position, BoardManager.player_move_time * 0.5)


func turn(dir : String):
	BoardManager.switch_screen_to_grid()
	grid_manager.turn(dir)
	cam_tween = get_tree().create_tween().bind_node(cam)
	match dir:
		"left":
			cam_tween.tween_property(cam, "rotation:y", cam.rotation.y + deg_to_rad(90.0), BoardManager.player_move_time)
		"right":
			cam_tween.tween_property(cam, "rotation:y", cam.rotation.y + deg_to_rad(-90.0), BoardManager.player_move_time)
			
	play_turn_sfx()


func zoom_in():
	BoardManager.switch_screen_to_grid()
	grid_manager.zoom_in()


func zoom_out():
	BoardManager.switch_screen_to_grid()
	grid_manager.zoom_out()


func print_to_terminal(new_message : Array[String]) -> void:
	BoardManager.switch_screen_to_terminal()
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
			var skeleton:Skeleton = skeleton_check_ray.get_collider()
			if not is_instance_valid(skeleton):
				push_error("Collided with a non-skeleton in skeleton ray check. Check layers plz!")
				return
				
			await BoardManager.talking_zoom_in(skeleton.zoom_position)
			print_to_terminal(skeleton.talk_message)
	else:
		print_to_terminal(default_talk_message)


func print_new_card(blank_card : PunchCard):
	var current_cell = grid_manager.position_dict[current_position]
	if current_cell.has_card_unlock:
		var new_card : PunchCard = current_cell.card_to_unlock.instantiate()
		var current_slot : CardSlot
		for slot in card_slots:
			if slot.has_card():
				current_slot = slot
		current_slot.current_card = new_card
		blank_card.get_parent().add_child(new_card)
		new_card.reactor = blank_card.reactor
		new_card.parent_surface = blank_card.parent_surface
		new_card.is_slotted = blank_card.is_slotted
		new_card.original_position = blank_card.original_position
		new_card.global_position = blank_card.global_position - Vector3(0,0,1)
		new_card.global_rotation = blank_card.global_rotation
		blank_card.queue_free()
		current_cell.has_card_unlock = false


func read_scripture(type : String):
	var verse : Array[String] = [""]
	match type:
		"scary":
			verse = [Scripture.random_scary()]
		"hopeful":
			verse = [Scripture.random_hopeful()]
	BoardManager.switch_screen_to_terminal()
	print_to_terminal(verse)

var _last_step_sound:int = 0
func play_footsteps() -> void:
	if footstep_sfx.is_empty():
		return
		
	var footstep_sound := footstep_sfx[_last_step_sound]
	footstep_player.stream = footstep_sound
	footstep_player.play()
	
	_last_step_sound = (_last_step_sound + 1) % footstep_sfx.size()

var _last_turn_sound:int = 0
func play_turn_sfx() -> void:
	if turn_sfx.is_empty():
		return
		
	var turn_sound := turn_sfx[_last_turn_sound]
	footstep_player.stream = turn_sound
	footstep_player.play()
	
	_last_turn_sound = (_last_turn_sound + 1) % turn_sfx.size()

func play_error_bonk() -> void:
	if is_instance_valid(bonk_sfx):
		footstep_player.stream = bonk_sfx
		footstep_player.play()
		
