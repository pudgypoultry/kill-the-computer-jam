extends PunchCard

func execute() -> void:
	super()
	# Check for valid move
	print_debug("Moving Forward")
	reactor.move_forward()


func execute_a() -> void:
	super()
	# Check for valid move
	print_debug("Zooming In")
	reactor.zoom_in()

func execute_b() -> void:
	super()
	# Check for valid move
	print_debug("Moving Forward")
	reactor.move_forward()
