extends Node2D
class_name GridManager

enum Direction {NORTH, EAST, SOUTH, WEST}

@export_category("Game Rules")
@export var grid_offset : float = 5
@export var height : int = 7
@export var width : int = 5
#@export var height : int = 30
#@export var width : int = 40
@export var generating : bool = false
@export var saving : bool = false
@export var file_name : String = "TestGrid.tscn"

@export_category("Plugging in Nodes")
@export var cell_scene : PackedScene
@export var cell_folder : Node2D
@export var player_marker : Node2D
@export var camera : Camera2D
@export var premade_grid : PackedScene

var current_direction : Direction = Direction.NORTH
var cell_grid : Array[Array]
var sprite_width : int
var sprite_height : int
var current_position : Vector2i
var current_facing : Vector2i
var player_tween : Tween
var camera_tween : Tween
var position_dict : Dictionary[Vector2i, GridCell] = {}
var original_zoom : float


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Generate 2d grid of squares
	var probe_scene : GridCell = cell_scene.instantiate()
	sprite_width = probe_scene.sprite.texture.get_width()
	sprite_height = probe_scene.sprite.texture.get_height()
	original_zoom = camera.zoom.x
	probe_scene.queue_free()
	if generating:
		generate_grid()
	else:
		var grid = premade_grid.instantiate()
		add_child(grid)
		for current_cell in grid.get_children():
			position_dict[current_cell.grid_position] = current_cell
			current_cell.grid_manager = self
			
	call_deferred("_late_ready")


func _late_ready():
	camera.global_position = position_dict[current_position].global_position
	player_marker.global_position = position_dict[current_position].global_position
	if saving:
		save_branch_as_scene(cell_folder, "Grids/" + file_name)


func generate_grid() -> void:
	# First pass to generate
	# If not generating, prepare the needed data from the supplied grid 
	for i in range(height):
		for j in range(width):
			var current_cell = cell_scene.instantiate()
			cell_folder.add_child(current_cell)
			current_cell.position += Vector2(j * sprite_width, i * sprite_height)
			current_cell.position.x += j * grid_offset
			current_cell.position.y += i * grid_offset
			current_cell.grid_position = Vector2i(j,i)
			current_cell.grid_manager = self
			current_cell.name = str(j) + "_" + str(i)
			position_dict[current_cell.grid_position] = current_cell
	
	# Second pass to fill out adjacencies
	for i in range(height):
		for j in range(width):
			var current_cell : GridCell = position_dict[Vector2i(j,i)]
			var north : Vector2i = current_cell.grid_position + Vector2i(0, -1)
			var east : Vector2i = current_cell.grid_position + Vector2i(1, 0)
			var south : Vector2i = current_cell.grid_position + Vector2i(0, 1)
			var west : Vector2i = current_cell.grid_position + Vector2i(-1, 0)
			if north in position_dict.keys():
				if position_dict[north].active:
					current_cell.adjacencies.append(position_dict[north])
			if east in position_dict.keys():
				if position_dict[east].active:
					current_cell.adjacencies.append(position_dict[east])
			if south in position_dict.keys():
				if position_dict[south].active:
					current_cell.adjacencies.append(position_dict[south])
			if west in position_dict.keys():
				if position_dict[west].active:
					current_cell.adjacencies.append(position_dict[west])


func save_branch_as_scene(branch_root: Node, file_path: String) -> void:
	if not branch_root:
		push_error("Cannot save: Provided branch root is null.")
		return

	# 1. Recursively set the owner of all child nodes to the branch_root
	set_owner_recursive(branch_root, branch_root)

	# 2. Pack the node branch into a scene resource
	var packed_scene = PackedScene.new()
	var error = packed_scene.pack(branch_root)
	
	if error == OK:
		# 3. Save the resource to disk
		var save_error = ResourceSaver.save(packed_scene, file_path)
		if save_error == OK:
			print("Successfully saved branch to: ", file_path)
		else:
			push_error("Failed to save scene file. Error code: ", save_error)
	else:
		push_error("Failed to pack scene branch. Error code: ", error)


func set_owner_recursive(node: Node, scene_root: Node) -> void:
	for child in node.get_children():
		# Skip nodes that are internal or shouldn't be saved (like temporary gameplay objects)
		if child.owner != scene_root:
			child.owner = scene_root
		
		# Continue down the hierarchy
		set_owner_recursive(child, scene_root)


func move_forward():
	player_tween = get_tree().create_tween().bind_node(player_marker)
	camera_tween = get_tree().create_tween().bind_node(camera)
	var forward = get_forward_direction()
	print("Moving in Direction:	", get_forward_direction())
	var target_position = player_marker.global_position + (get_forward_direction() * sprite_width)
	if forward.x != 0:
		target_position.x += grid_offset * forward.x
	if forward.y != 0:
		target_position.y += grid_offset * forward.y
	player_tween.tween_property(player_marker, "global_position", target_position, BoardManager.player_move_time)
	camera_tween.tween_property(camera, "global_position", target_position, BoardManager.player_move_time)
	current_position = current_position + (get_forward_direction() as Vector2i)


func move_backward():
	player_tween = get_tree().create_tween().bind_node(player_marker)
	camera_tween = get_tree().create_tween().bind_node(camera)
	var backward = -get_forward_direction()
	print("Moving in Direction:	", get_forward_direction())
	var target_position = player_marker.global_position + (backward * sprite_width)
	if backward.x != 0:
		target_position.x += grid_offset * backward.x
	if backward.y != 0:
		target_position.y += grid_offset * backward.y
	player_tween.tween_property(player_marker, "global_position", target_position, BoardManager.player_move_time)
	camera_tween.tween_property(camera, "global_position", target_position, BoardManager.player_move_time)
	current_position = current_position - (get_forward_direction() as Vector2i)


func turn(dir : String):
	player_tween = get_tree().create_tween().bind_node(player_marker)
	#camera_tween = get_tree().create_tween().bind_node(camera)
	print("====================")
	print("Was facing:	", current_direction)
	match dir:
		"left":
			player_tween.tween_property(player_marker, "rotation_degrees", player_marker.rotation_degrees - 90, BoardManager.player_move_time)
			match current_direction:
				Direction.NORTH:
					current_direction = Direction.WEST
				Direction.EAST:
					current_direction = Direction.NORTH
				Direction.SOUTH:
					current_direction = Direction.EAST
				Direction.WEST:
					current_direction = Direction.SOUTH
		"right":
			player_tween.tween_property(player_marker, "rotation_degrees", player_marker.rotation_degrees + 90, BoardManager.player_move_time)
			match current_direction:
				Direction.NORTH:
					current_direction = Direction.EAST
				Direction.EAST:
					current_direction = Direction.SOUTH
				Direction.SOUTH:
					current_direction = Direction.WEST
				Direction.WEST:
					current_direction = Direction.NORTH
	print("Now facing:	", current_direction)
	print("====================")


func get_forward_direction():
	match current_direction:
		Direction.NORTH:
			return Vector2(0, -1)
		Direction.EAST:
			return Vector2(1, 0)
		Direction.SOUTH:
			return Vector2(0, 1)
		Direction.WEST:
			return Vector2(-1, 0)


func zoom_in():
	if camera.zoom.x < original_zoom * 2:
		camera.zoom *= 2.0


func zoom_out():
	if camera.zoom.x > original_zoom / 4:
		camera.zoom *= 0.5
