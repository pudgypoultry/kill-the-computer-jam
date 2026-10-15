extends Node3D

@export var reactor:Reactor

@export var song_1_duration:float
@export var song_2_duration:float
@export var song_3_duration:float

@onready var fader: ColorRect = %Fader
@onready var music_player: AudioStreamPlayer = %MusicPlayer
@onready var icosphere: MeshInstance3D = %Icosphere
 
var _started:bool = false

var ico_mat:ShaderMaterial

var craziness:float:
	set(value):
		craziness = value
		if is_instance_valid(ico_mat):
			ico_mat.set_shader_parameter("offset", craziness)

func _ready() -> void:
	if reactor == null:
		return
	
	while not reactor.is_inside_tree():
		await get_tree().process_frame
		
	reactor.reactor_state = Reactor.ReactorState.Calm
	fader.color = Color.WHITE
	
	ico_mat = icosphere.get_active_material(0).duplicate() as ShaderMaterial
	icosphere.material_override = ico_mat

var _band_window_1:Array[float]
var _band_window_2:Array[float]
var _band_window_3:Array[float]
var _band_window_4:Array[float]

const _max_band_size:int = 30

func _process(_delta:float) -> void:
	var music_idx = AudioServer.get_bus_index("Music")
	var analyzer:AudioEffectSpectrumAnalyzerInstance = AudioServer.get_bus_effect_instance(music_idx, 0) as AudioEffectSpectrumAnalyzerInstance
	
	var band_4 = analyzer.get_magnitude_for_frequency_range(0, 250).length()
	var band_3 = analyzer.get_magnitude_for_frequency_range(250, 500).length()
	var band_2 = analyzer.get_magnitude_for_frequency_range(500, 2000).length()
	var band_1 = analyzer.get_magnitude_for_frequency_range(2000, 10000).length()
	
	_band_window_1.push_back(band_1)
	if _band_window_1.size() > _max_band_size:
		_band_window_1.pop_front()

	_band_window_2.push_back(band_2)
	if _band_window_2.size() > _max_band_size:
		_band_window_2.pop_front()

	_band_window_3.push_back(band_3)
	if _band_window_3.size() > _max_band_size:
		_band_window_3.pop_front()

	_band_window_4.push_back(band_3)
	if _band_window_4.size() > _max_band_size:
		_band_window_4.pop_front()
		
	band_1 = 0.0
	for band_sample in _band_window_1:
		band_1 += band_sample
	band_1 /= _band_window_1.size() as float

	band_2 = 0.0
	for band_sample in _band_window_2:
		band_2 += band_sample
	band_2 /= _band_window_2.size() as float

	band_3 = 0.0
	for band_sample in _band_window_3:
		band_3 += band_sample
	band_3 /= _band_window_3.size() as float

	band_4 = 0.0
	for band_sample in _band_window_4:
		band_4 += band_sample
	band_4 /= _band_window_4.size() as float

	ico_mat.set_shader_parameter("band_1", band_1)
	ico_mat.set_shader_parameter("band_2", band_2)
	ico_mat.set_shader_parameter("band_3", band_3)
	ico_mat.set_shader_parameter("band_4", band_4)

func _unhandled_input(event: InputEvent) -> void:
	if event is not InputEventKey or _started:
		return
		
	var key_event := event as InputEventKey
	if key_event.keycode == KEY_ENTER:
		_started = true
		_start()
		
func _start() -> void:
	fader.color = Color.BLACK
	await get_tree().create_timer(0.5).timeout
	music_player.play(0.0)
	var tween = get_tree().create_tween()
	tween.parallel()
	tween.tween_property(fader, "color", Color(0.0, 0.0, 0.0, 0.0),3.0)
	tween.tween_property(music_player, "volume_linear", db_to_linear(-1.0), 3.0)
	craziness = 0.5
	
	await get_tree().create_timer(song_1_duration).timeout
	
	reactor.reactor_state = Reactor.ReactorState.Agitated
	tween = get_tree().create_tween()
	tween.tween_property(self, "craziness", 1.0 ,3.0)	
	
	await get_tree().create_timer(song_2_duration).timeout
	
	reactor.reactor_state = Reactor.ReactorState.Critical
	tween = get_tree().create_tween()
	tween.tween_property(self, "craziness", 1.5 ,3.0)	
	
	await get_tree().create_timer(song_3_duration).timeout

	tween = get_tree().create_tween()
	tween.tween_property(fader, "color", Color(0.0, 0.0, 0.0, 1.0),3.0)
