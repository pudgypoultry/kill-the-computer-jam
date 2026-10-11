extends Node
class_name SpriteOutlineComponent

var actor_reference : Sprite3D
var original_alpha_threshold : float = 0.2

var _should_show_outline : bool = false

func _ready() -> void:
	actor_reference = get_parent().sprite
	if not actor_reference.material_override:
		_apply_material_override()
	
	_apply_texture()
	actor_reference.texture_changed.connect(_apply_texture)
	
	BoardManager.player_control_changed.connect(_on_player_control_changed)

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
	_should_show_outline = true
	
	if not BoardManager.player_actionable:
		return
	
	_show_outline_internal()

func _show_outline_internal() -> void:
	var shader_material : ShaderMaterial = actor_reference.material_override
	shader_material.set_shader_parameter("alphaThreshold", original_alpha_threshold)
	var mouse_cursor = MouseCursor.get_global_cursor()
	mouse_cursor.add_highlight_target(self)

func hide_outline():
	_should_show_outline = false
	_hide_outline_internal()

func _hide_outline_internal():
	var shader_material : ShaderMaterial = actor_reference.material_override
	shader_material.set_shader_parameter("alphaThreshold", 0.0)
	var mouse_cursor = MouseCursor.get_global_cursor()
	mouse_cursor.remove_highlight_target(self)

func _on_player_control_changed(value:bool) -> void:
	if not value:
		_hide_outline_internal()
	else:		
		if _should_show_outline:
			_show_outline_internal()
		else:
			_hide_outline_internal()
