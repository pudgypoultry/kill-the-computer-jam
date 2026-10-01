@tool

extends Node3D
class_name EnvironmentLight

@export var mesh_material : ORMMaterial3D
@export var light_colour : Color = Color.WHITE:
	set(value):
		light_colour = value
		_update_light_params()
		
@export_range(0.0, 10.0) var emissive_brightness : float = 5.0:
	set(value):
		emissive_brightness = value
		_update_light_params()

@export_range(0.0, 10.0) var light_brightness : float = 1.0:
	set(value):
		light_brightness = value
		_update_light_params()

@export_range(0.0, 10.0) var light_fog_amount : float = 5.0:
	set(value):
		light_fog_amount = value
		_update_light_params()

@export_range(0.0, 50.0) var light_range : float = 5.0:
	set(value):
		light_range = value
		_update_light_params()
		
@export var cast_shadows:bool = false:
	set(value):
		cast_shadows = value
		_update_light_params()

@onready var light_mesh: MeshInstance3D = %LightMesh
@onready var light: SpotLight3D = %Light

var _material : ORMMaterial3D

func _ready() -> void:
	if is_instance_valid(mesh_material):		
		_material = mesh_material.duplicate()
		light_mesh.set_surface_override_material(0, _material)
		
	_update_light_params()
		
func _update_light_params() -> void:
	if is_instance_valid(_material):
		_material.emission = light_colour
		
	if is_instance_valid(light):
		light.light_color = light_colour
		light.light_volumetric_fog_energy = light_fog_amount
		light.shadow_enabled = cast_shadows
		light.spot_range = light_range
		
	_update_light_intensity()

# override this for flickering, etc. behaviour
func _update_light_intensity() -> void:
	if is_instance_valid(_material):
		_material.emission_energy_multiplier = emissive_brightness
		
	if is_instance_valid(light):
		light.light_energy = light_brightness
