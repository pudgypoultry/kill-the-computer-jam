extends Node
class_name SpriteOutlineComponent

var actor_reference : Sprite3D
var original_alpha_threshold : float = 0.2

func _ready() -> void:
	actor_reference = get_parent().sprite
	if not actor_reference.material_override:
		_apply_material_override()
	
	_apply_texture()
	actor_reference.texture_changed.connect(_apply_texture)


func _apply_material_override():
	var shader_material = ShaderMaterial.new()
	shader_material.shader = load("res://Components/SpriteOutlineComponent/SpriteHighlight.gdshader")
	actor_reference.material_override = shader_material


func _apply_texture():
	var shader_material : ShaderMaterial = actor_reference.material_override
	shader_material.set_shader_parameter("sprite_texture", actor_reference.texture)
	shader_material.set_shader_parameter("alphaThreshold", 0.0)
	shader_material.set_shader_parameter("glowSize", 25.0)
	shader_material.set_shader_parameter("glowSharpness", 5.0)


func show_outline():
	var shader_material : ShaderMaterial = actor_reference.material_override
	shader_material.set_shader_parameter("alphaThreshold", original_alpha_threshold)


func hide_outline():
	var shader_material : ShaderMaterial = actor_reference.material_override
	shader_material.set_shader_parameter("alphaThreshold", 0.0)
