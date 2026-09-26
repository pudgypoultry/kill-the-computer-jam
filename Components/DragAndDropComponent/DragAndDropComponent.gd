extends Node
class_name DragAndDropComponent

@export var check_ray : RayCast3D
@export var ghost_source : GeometryInstance3D   # the card's Sprite3D or MeshInstance3D
@export_flags_3d_physics var checkray_layers
@export var pickup_height : float = 0.1
@export var drag_speed_x : float = 0.3
@export var drag_speed_z : float = 0.15
@export var follow_speed : float = 30.0
@export var debug : bool = false
@export var sprite_outline_component : SpriteOutlineComponent

var actor_reference : Node3D
var is_current_focus : bool = false
var is_being_dragged : bool = false
var is_slottable : bool
var original_position : Vector3 = Vector3.ZERO
var original_parent : Node3D
var potential_drop : Node3D
var valid_drop : bool
var pickup_timer : float = 0.0
var pickup_interval : float = 0.1
var can_pickup : bool = true
var camera : Camera3D
var surface : StaticBody3D
var grab_offset : Vector3 = Vector3.ZERO
var drag_plane : Plane
var is_highlighted : bool = false


func _ready() -> void:
	actor_reference = get_parent()
	actor_reference.add_to_group("IsDraggable")
	if !pickup_height:
		pickup_height = actor_reference.pickup_height
	original_position = actor_reference.global_position
	# print(name, " is trying to assign as parent:	", actor_reference.get_parent())
	original_parent = actor_reference.get_parent()
	actor_reference.set_collision_layer_value(2, true)
	actor_reference.connect("mouse_entered", _on_mouse_entered)
	actor_reference.connect("mouse_exited", _on_mouse_exited)
	camera = get_viewport().get_camera_3d()
	call_deferred("_late_ready")
#ajdkjaskdjlaskdj


func _late_ready() -> void:
	surface = actor_reference.parent_surface


func _process(delta: float) -> void:
	if !can_pickup:
		pickup_timer += delta
		if pickup_timer >= pickup_interval:
			can_pickup = true
	
	if is_being_dragged:
		drag(delta)
	if Input.is_action_just_released("pick_up") && is_being_dragged:
		drop()
	if Input.is_action_just_pressed("pick_up") && BoardManager.current_focus == actor_reference:
		pick_up()

	if BoardManager.current_focus == actor_reference:
		if sprite_outline_component && !is_highlighted:
			sprite_outline_component.show_outline()
			is_highlighted = true
	else:
		if sprite_outline_component && is_highlighted:
			sprite_outline_component.hide_outline()
			is_highlighted = false


func pick_up():
	if !can_pickup:
		return
	is_being_dragged = true
	original_position = actor_reference.global_position
	if actor_reference.get_parent() != original_parent:
		actor_reference.reparent(original_parent)

	var normal : Vector3 = surface.global_transform.basis.y.normalized()
	var lifted : Vector3 = original_position + normal * pickup_height
	drag_plane = Plane(normal, lifted)


func drag(delta):
	BoardManager.last_pickup_position = actor_reference.global_position
	var hit = get_mouse_hit_on_plane(drag_plane)
	if hit == null:
		return
	var target : Vector3 = hit + grab_offset
	# Frame-rate independent exponential smoothing
	var weight := 1.0 - exp(-follow_speed * delta)
	actor_reference.global_position = actor_reference.global_position.lerp(target, weight)


func drop():
	# check if position is allowed
	if !check_ray.is_colliding():
		return
	# find drop position
	var collider = check_ray.get_collider()
	var drop_position = check_ray.get_collision_point()
	# Layer 2 is the table itself
	if collider.get_collision_layer_value(2):
		actor_reference.global_position = Vector3(drop_position.x, BoardManager.board_height, drop_position.z)
	# Layer 3 is the slot position
	elif collider.get_collision_layer_value(3):
		collider.slot_card(actor_reference)
		# Call slot function, pass it this card
	just_dropped()


func is_valid_drop() -> bool:
	if !check_ray.is_colliding():
		return false
	var landing_on = check_ray.get_collider().get_collision_layer() & (checkray_layers)
	if !landing_on:
		return false
	else:
		return true


func just_dropped():
	BoardManager.current_focus = null
	pickup_timer = 0.0
	can_pickup = false
	is_being_dragged = false


func get_mouse_hit_on_plane(plane: Plane):
	var mouse_pos := get_viewport().get_mouse_position()
	var from := camera.project_ray_origin(mouse_pos)
	var dir := camera.project_ray_normal(mouse_pos)
	return plane.intersects_ray(from, dir)


func _on_mouse_entered():
	BoardManager.current_focus = actor_reference

func _on_mouse_exited():
	if BoardManager.current_focus == actor_reference:
		BoardManager.current_focus = null
