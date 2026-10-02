extends PunchCard

func execute() -> void:
	super()
	print("Rotating Right")
	reactor.turn("right")

func execute_a() -> void:
	super()
	BoardManager.reactor_manager.examine()
	BoardManager.switch_screen_to_terminal()

func execute_b() -> void:
	super()
	print("Rotating Right")
	reactor.turn("right")
