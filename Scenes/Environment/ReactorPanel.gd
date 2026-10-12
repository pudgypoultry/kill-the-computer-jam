extends Door
class_name ReactorPanel

@export var reactor : Reactor
@export var explosion_intensity : float = 10.0
@export var explosion_delay : float = 3.0
@export var explosion_interval : float = 1.0

func open_correct(_player : Node3D):
	reactor.reactor_state = Reactor.ReactorState.Calm
	# move player camera however need be

func open_wrong(_player : Node3D):
	reactor.reactor_state = Reactor.ReactorState.Critical
	# move player camera however need be
	explode()

func change_reactor_color(state : Reactor.ReactorState):
	reactor.reactor_state = state


func explode():
	pass
	# increase light behind faceplate camera
	var light = BoardManager.explosion_light
	var tween = get_tree().create_tween().bind_node(light)
	await get_tree().create_timer(explosion_delay).timeout
	tween.tween_property(light, "light_specular", explosion_intensity, explosion_interval)
	# play sound effect
