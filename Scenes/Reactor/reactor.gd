extends Node3D
class_name Reactor

@onready var reactor_rods: ReactorRodsMesh = %ReactorRods
@onready var reactor_glow: MeshInstance3D = %ReactorGlow
@onready var reactor_under_light: SpotLight3D = %ReactorUnderLight
@onready var reactor_ambient_light: OmniLight3D = %ReactorAmbientLight
@onready var reactor_sound: AudioStreamPlayer3D = $ReactorSound
@onready var reactor_alarm: AudioStreamPlayer3D = $ReactorAlarm

@export var rod_material:ShaderMaterial:
	set(value):
		rod_material = value
		_update_materials()

@export var reactor_glow_material:StandardMaterial3D:
	set(value):
		reactor_glow_material = value
		_update_materials()

@export var reactor_state:ReactorState:
	set(value):
		_change_reactor_state(value)
	get():
		return _reactor_state

@export var reactor_noise_volume_db:float = 0.0:
	set(value):
		reactor_noise_volume_db = value
		_change_reactor_panic_sound()

@export var reactor_alarm_volume_db:float = 0.0:
	set(value):
		reactor_alarm_volume_db = value
		_change_reactor_alarm_fade()

var _reactor_panic_sound:float = 1.0:
	set(value):
		_reactor_panic_sound = value
		_change_reactor_panic_sound()

var _reactor_alarm_fade_amt:float = 0.0:
	set(value):
		_reactor_alarm_fade_amt = value
		_change_reactor_alarm_fade()

@export var state_change_time:float = 3.0

enum ReactorState
{
	Agitated,
	Calm,
	Critical
}

const agitated_colour := Color.RED
const calm_colour := Color.GREEN_YELLOW
const critical_colour := Color.DARK_ORANGE

var _reactor_state:ReactorState
var _reactor_state_tween:Tween
var _reactor_wave_time:float = 0.0

var _light_color:Color = Color.RED:
	set(value):
		_light_color = value
		_update_colour()

var _reactor_wave_amplitude:float = 1.0:
	set(value):
		_reactor_wave_amplitude = value
		_update_rod_amplitude()

var _reactor_wave_speed:float = 1.0:
	set(value):
		_reactor_wave_speed = value
		_update_rod_wave_speed()

var _reactor_chaos = 2.0:
	set(value):
		_reactor_chaos = value
		_update_rod_chaos()

var _cur_rod_material:ShaderMaterial
var _cur_glow_material:StandardMaterial3D

func _ready() -> void:
	_update_materials()
	_change_reactor_panic_sound()
	_change_reactor_alarm_fade()

func _process(delta:float) -> void:
	if is_instance_valid(_cur_rod_material):
		_reactor_wave_time += delta * _reactor_wave_speed
		_cur_rod_material.set_shader_parameter("wave_time", _reactor_wave_time)

func _get_colour_for_state() -> Color:
	match _reactor_state:
		ReactorState.Agitated:
			return agitated_colour
		ReactorState.Calm:
			return calm_colour
		ReactorState.Critical:
			return critical_colour
			
	return Color()
	
func _update_materials() -> void:
	if is_instance_valid(reactor_glow) and is_instance_valid(reactor_glow_material):
		_cur_glow_material = reactor_glow_material.duplicate()
		reactor_glow.material_override = _cur_glow_material
	if is_instance_valid(reactor_rods) and is_instance_valid(rod_material):
		_cur_rod_material = rod_material.duplicate()
		reactor_rods.material_override = _cur_rod_material
	
	# duping materials requires all state to be updated
	_update_colour()
	_update_rod_movement()

func _update_colour() -> void:
	if is_instance_valid(_cur_glow_material):
		_cur_glow_material.emission = _light_color
		
	if is_instance_valid(reactor_under_light):
		reactor_under_light.light_color = _light_color
		
	if is_instance_valid(reactor_ambient_light):
		reactor_ambient_light.light_color = _light_color
		
func _update_rod_movement() -> void:
	_update_rod_wave_speed()
	_update_rod_amplitude()
	_update_rod_chaos()
	
func _update_rod_wave_speed() -> void:
	if is_instance_valid(_cur_rod_material):
		_cur_rod_material.set_shader_parameter("wave_speed", _reactor_wave_speed)

func _update_rod_amplitude() -> void:
	if is_instance_valid(_cur_rod_material):
		_cur_rod_material.set_shader_parameter("max_move", _reactor_wave_amplitude)

func _update_rod_chaos() -> void:
	if is_instance_valid(_cur_rod_material):
		_cur_rod_material.set_shader_parameter("chaos", _reactor_chaos)

func _change_reactor_state(new_state:ReactorState) -> void:
	if new_state == _reactor_state:
		return
		
	_reactor_state = new_state
		
	if is_instance_valid(_reactor_state_tween) and _reactor_state_tween.is_running():
		_reactor_state_tween.stop()
		
	_reactor_state_tween = get_tree().create_tween()
	_reactor_state_tween.set_parallel()
	
	_reactor_state_tween.tween_property(self, "_light_color", _get_colour_for_state(), state_change_time)
	
	match _reactor_state:
		ReactorState.Agitated:
			_reactor_state_tween.tween_property(self, "_reactor_wave_amplitude", 1.0, state_change_time)
			_reactor_state_tween.tween_property(self, "_reactor_wave_speed", 1.0, state_change_time)
			_reactor_state_tween.tween_property(self, "_reactor_chaos", 2.0, state_change_time)
			_reactor_state_tween.tween_property(self, "_reactor_panic_sound", 1.0, state_change_time)
			_reactor_state_tween.tween_property(self, "_reactor_alarm_fade_amt", 0.0, state_change_time)
		ReactorState.Calm:
			_reactor_state_tween.tween_property(self, "_reactor_wave_amplitude", 0.5, state_change_time)
			_reactor_state_tween.tween_property(self, "_reactor_wave_speed", 0.5, state_change_time)
			_reactor_state_tween.tween_property(self, "_reactor_chaos", 0.0, state_change_time)
			_reactor_state_tween.tween_property(self, "_reactor_panic_sound", 0.0, state_change_time)
			_reactor_state_tween.tween_property(self, "_reactor_alarm_fade_amt", 0.0, state_change_time)
		ReactorState.Critical:
			_reactor_state_tween.tween_property(self, "_reactor_wave_amplitude", 1.25, state_change_time)
			_reactor_state_tween.tween_property(self, "_reactor_wave_speed", 1.5, state_change_time)
			_reactor_state_tween.tween_property(self, "_reactor_chaos", 5.0, state_change_time)			
			_reactor_state_tween.tween_property(self, "_reactor_panic_sound", 1.0, state_change_time)
			_reactor_state_tween.tween_property(self, "_reactor_alarm_fade_amt", 1.0, state_change_time)

func _change_reactor_panic_sound() -> void:
	if not is_instance_valid(reactor_sound):
		return
	
	var reactor_stream := reactor_sound.stream as AudioStreamSynchronized
	if not is_instance_valid(reactor_stream):
		push_error("Invalid reactor stream format")
		return
		
	# standard x-fade power curve
	var agitated_sound_db:float = linear_to_db(sqrt(_reactor_panic_sound))
	var calm_sound_db:float = linear_to_db(sqrt(1.0 - _reactor_panic_sound))
	
	print("set reactor agitated vol to " + str(agitated_sound_db))
	print("set reactor calm vol to " + str(calm_sound_db))
	
	reactor_stream.set_sync_stream_volume(0, agitated_sound_db)
	reactor_stream.set_sync_stream_volume(1, calm_sound_db)
	
	reactor_sound.volume_db = reactor_noise_volume_db

func _change_reactor_alarm_fade() -> void:
	if not is_instance_valid(reactor_alarm):
		return
		
	reactor_alarm.volume_linear = sqrt(_reactor_alarm_fade_amt) * db_to_linear(reactor_alarm_volume_db)
