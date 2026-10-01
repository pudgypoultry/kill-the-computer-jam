@tool
extends EnvironmentLight
class_name EnvironmentLightFlicker

var flicker_amount:float = 1.0

@export_range(0.0, 10.0) var flicker_rate_a:float = 0.333
@export_range(0.0, 10.0) var flicker_rate_b:float = 2.0

@export_range(0.0, 1.0) var flicker_threshold:float = 0.6

@export_range(0.01, 100.0) var flicker_adjust_speed:float = 5.0

@export_range(0.0, 1.0) var flicker_high_amount:float = 1.0
@export_range(0.0, 1.0) var flicker_low_amount:float = 0.5

var time_tracking:float = 0.0

func _ready() -> void:
	super._ready()
	
	time_tracking = randf_range(0.0, 2.0 * PI)

func _process(delta: float) -> void:
	time_tracking += delta
	
	var flicker_a_val:float = abs(cos(time_tracking * flicker_rate_a * 2.0 * PI))
	var flicker_b_val:float = abs(cos(time_tracking * flicker_rate_b * 2.0 * PI))
	
	var flicker_target:float = 1.0 if flicker_a_val + flicker_b_val > (flicker_threshold * 2.0) else 0.0
	flicker_amount = move_toward(flicker_amount, lerp(flicker_low_amount, flicker_high_amount, flicker_target), flicker_adjust_speed * delta)
	
	_update_light_intensity()
	
# override this for flickering, etc. behaviour
func _update_light_intensity() -> void:
	if is_instance_valid(_material):
		_material.emission_energy_multiplier = emissive_brightness * flicker_amount
		
	if is_instance_valid(light):
		light.light_energy = light_brightness * flicker_amount
	
