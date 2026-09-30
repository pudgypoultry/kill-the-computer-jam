extends Node2D
class_name GridManager

enum Direction {NORTH, EAST, SOUTH, WEST}

@export_category("Game Rules")
@export var grid_offset : float = 5
@export var height : int = 30
@export var width : int = 40

@export_category("Plugging in Nodes")
@export var cell_scene : PackedScene
@export var cell_folder : Node2D
@export var player_marker : Node2D
@export var camera : Camera2D

var current_direction : Direction = Direction.NORTH
var cell_grid : Array[Array]
var sprite_width : int
var sprite_height : int
var current_position : Vector2i
var current_facing : Vector2i
var player_tween : Tween
var camera_tween : Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Generate 2d grid of squares
	var probe_scene : GridCell = cell_scene.instantiate()
	sprite_width = probe_scene.sprite.texture.get_width()
	sprite_height = probe_scene.sprite.texture.get_height()
	probe_scene.queue_free()
	generate_grid()
	# Turn on all positions with a 1
	# Set up player marker
	await get_tree().create_timer(1.1).timeout
	turn("right")
	await get_tree().create_timer(1.1).timeout
	move_forward()
	await get_tree().create_timer(1.1).timeout
	turn("right")
	await get_tree().create_timer(1.1).timeout
	move_forward()
	await get_tree().create_timer(1.1).timeout
	turn("left")
	await get_tree().create_timer(1.1).timeout
	move_forward()
	await get_tree().create_timer(1.1).timeout
	turn("right")
	await get_tree().create_timer(1.1).timeout
	move_forward()


func generate_grid() -> void:
	for i in range(height):
		for j in range(width):
			var current_cell = cell_scene.instantiate()
			cell_folder.add_child(current_cell)
			current_cell.position += Vector2(j * sprite_width, i * sprite_height)
			current_cell.position.x += j * grid_offset
			current_cell.position.y += i * grid_offset


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
	player_tween.tween_property(player_marker, "global_position", target_position, 1.0)
	camera_tween.tween_property(camera, "global_position", target_position, 1.0)


func turn(dir : String):
	player_tween = get_tree().create_tween().bind_node(player_marker)
	print("====================")
	print("Was facing:	", current_direction)
	match dir:
		"left":
			player_tween.tween_property(player_marker, "rotation_degrees", player_marker.rotation_degrees - 90, 1.0)
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
			player_tween.tween_property(player_marker, "rotation_degrees", player_marker.rotation_degrees + 90, 1.0)
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
