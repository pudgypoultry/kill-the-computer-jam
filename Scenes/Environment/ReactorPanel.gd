extends Door
class_name ReactorPanel

@export var reactor : Reactor

func open_correct(player : Node3D):
	_play_accept_effect()
	BoardManager.add_player_actionable_blocker(self)
	reactor.reactor_state = Reactor.ReactorState.Calm
	# move player camera however need be
	await get_tree().create_timer(3.5).timeout
	var player_tween = get_tree().create_tween().bind_node(player)
	player_tween.tween_property(player, "position:z", player.position.z + 3, 3.0)
	await get_tree().create_timer(3.5).timeout
	player_tween = get_tree().create_tween().bind_node(player)
	player_tween.tween_property(player, "position:y", player.position.y - 0.5, 3.0)
	await get_tree().create_timer(3.5).timeout
	player_tween = get_tree().create_tween().bind_node(player)
	player_tween.tween_property(player, "rotation:x", player.rotation.x + deg_to_rad(20), 2.0)
	var fade_out = BoardManager.fade_out_screen
	await get_tree().create_timer(2.0).timeout
	fade_out.fade_out()

func open_wrong(_player : Node3D):
	_play_accept_effect()
	BoardManager.add_player_actionable_blocker(self)
	reactor.reactor_state = Reactor.ReactorState.Critical

func change_reactor_color(state : Reactor.ReactorState):
	reactor.reactor_state = state
