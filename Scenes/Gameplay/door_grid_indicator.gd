extends Node3D
class_name GridIndicator

@onready var grid_mesh: MeshInstance3D = %GridMesh

var material:ShaderMaterial;

@export var light_colour:Color:
	set(value):
		light_colour = value
		_update_light_colour()

@export var blink_rate:float = 2.0
@export var blink_bias:float = 0.5
@export var is_blinking:bool = true:
	set(value):
		is_blinking = value
		_blink_timer = 0.0
		
@export var is_on:bool = false

var _blink_strength:float = 1.0
var _blink_timer:float = 0.0

# Why did I make this zero based and the shader one based? I blame cold medication
var parameter_lookup:Dictionary[Vector2i, String] = {
	Vector2i(0, 0): "grid_1_1",
	Vector2i(1, 0): "grid_2_1",
	Vector2i(2, 0): "grid_3_1",
	Vector2i(3, 0): "grid_4_1",
	Vector2i(4, 0): "grid_5_1",

	Vector2i(0, 1): "grid_1_2",
	Vector2i(1, 1): "grid_2_2",
	Vector2i(2, 1): "grid_3_2",
	Vector2i(3, 1): "grid_4_2",
	Vector2i(4, 1): "grid_5_2",

	Vector2i(0, 2): "grid_1_3",
	Vector2i(1, 2): "grid_2_3",
	Vector2i(2, 2): "grid_3_3",
	Vector2i(3, 2): "grid_4_3",
	Vector2i(4, 2): "grid_5_3",

	Vector2i(0, 3): "grid_1_4",
	Vector2i(1, 3): "grid_2_4",
	Vector2i(2, 3): "grid_3_4",
	Vector2i(3, 3): "grid_4_4",
	Vector2i(4, 3): "grid_5_4",

	Vector2i(0, 4): "grid_1_5",
	Vector2i(1, 4): "grid_2_5",
	Vector2i(2, 4): "grid_3_5",
	Vector2i(3, 4): "grid_4_5",
	Vector2i(4, 4): "grid_5_5",
}

func _ready() -> void:
	if is_instance_valid(grid_mesh):
		material = grid_mesh.get_active_material(0).duplicate() as ShaderMaterial
		grid_mesh.material_override = material
		_update_light_colour()		

func _process(delta:float) -> void:
	if is_blinking:
		_blink_timer += delta
		_blink_strength = 1.0 if (0.5 * (1.0 + cos(_blink_timer * blink_rate * 2.0 * PI)) >= blink_bias) else 0.0
	else:
		_blink_strength = 1.0
	
	_update_light_colour()

func _set_grid_position(x:int, y:int, strength:float) -> void:
	var position_vec := Vector2i(x, y)
	if not parameter_lookup.has(position_vec):
		return
		
	var param_name := parameter_lookup[position_vec]
	material.set_shader_parameter(param_name, strength)
	
func _update_light_colour() -> void:
	if is_instance_valid(material):
		material.set_shader_parameter("emissive_color", light_colour * _blink_strength if is_on else Color.BLACK)

# Example usage: set_light_pattern("ooxoo oxxxo ooxoo xoxox ooxoo")
func set_light_pattern(pattern:String) -> void:
	var x_count:int = 0
	var y_count:int = 0
	for i in pattern.length():
		if pattern[i] == 'x':
			_set_grid_position(x_count, y_count, 1.0)
		elif pattern[i] == 'o':
			_set_grid_position(x_count, y_count, 0.0)
		else:
			continue
			
		x_count += 1
		if x_count >= 5:
			x_count = 0
			y_count += 1
			
		if y_count >= 5:
			break
