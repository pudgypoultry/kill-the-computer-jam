extends PunchCard

func execute() -> void:
	super()
	print_debug("Moving Backward")
	reactor.move_backward()


func execute_a() -> void:
	super()
	# Check for valid move
	print_debug("Zooming Out")
	BoardManager.switch_screen_to_grid()
	reactor.zoom_out()


func execute_b() -> void:
	super()
	# Check for valid move
	print_debug("Moving Backward")
	reactor.move_backward()
