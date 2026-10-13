extends Camera3D
class_name GameCamera

@export var noise_speed: float = 00
@export var noise_strength = 0.0

var noise:FastNoiseLite
var noise_time:float = 0.0

func _ready() -> void:
	noise = FastNoiseLite.new()
	noise.seed = randi()
	noise.frequency = 2.0

func _process(delta:float) -> void:
	noise_time += delta * noise_speed
	var noise_amt_h = noise.get_noise_2d(1.0, noise_time)
	var noise_amt_v = noise.get_noise_2d(11.3291, noise_time)
	h_offset = noise_amt_h * noise_strength
	v_offset = noise_amt_v * noise_strength
