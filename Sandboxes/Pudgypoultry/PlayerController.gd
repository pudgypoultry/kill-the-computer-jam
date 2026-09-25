extends CharacterBody3D


const SPEED = 5.0
@export var mouse_sensitivity = 0.05
@export var rotation_bounds = 80
@export var interact_ray : RayCast3D

var mouse_x_input : float = 0.0
var mouse_y_input : float = 0.0
var current_target : Node3D = null

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _process(delta : float) -> void:
	check_ray()
	attempt_interact()
	handle_mouse_mode()


func _physics_process(delta : float) -> void:
	movement_behavior(delta)
	move_and_slide()


func _unhandled_input(event : InputEvent) -> void:
	rotation_behavior(event)


func rotation_behavior(event : InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity * 0.25)
		rotation.x += -event.relative.y * mouse_sensitivity * 0.25
		rotation.x = clampf(rotation.x, deg_to_rad(-rotation_bounds), deg_to_rad(rotation_bounds))


func movement_behavior(delta : float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)


func handle_mouse_mode() -> void:
	if Input.is_action_just_pressed("escape"):
		match Input.mouse_mode:
			Input.MOUSE_MODE_CAPTURED:
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			Input.MOUSE_MODE_VISIBLE:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func check_ray():
	if interact_ray.is_colliding():
		if interact_ray.get_collider() is Interactable && interact_ray.get_collider() != current_target:
			change_target(interact_ray.get_collider())
	else:
		if current_target != null:
			change_target(null)


func change_target(new_target : Node3D):
	if current_target:
		print("Old Target:	", current_target)
		current_target.unhighlight()
	current_target = new_target
	if new_target:
		current_target.highlight()
		print("New Target:	", current_target)


func attempt_interact():
	if Input.is_action_just_pressed("interact") && current_target:
		current_target.interact()
