extends Door
class_name ReactorPanel

@export var reactor : Reactor

func open_correct(_player : Node3D):
	_play_accept_effect()
	BoardManager.add_player_actionable_blocker(self)
	reactor.reactor_state = Reactor.ReactorState.Calm
	# move player camera however need be

func open_wrong(_player : Node3D):
	_play_accept_effect()
	BoardManager.add_player_actionable_blocker(self)
	reactor.reactor_state = Reactor.ReactorState.Critical

func change_reactor_color(state : Reactor.ReactorState):
	reactor.reactor_state = state
