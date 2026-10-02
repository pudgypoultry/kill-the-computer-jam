extends PunchCard

func execute() -> void:
	super()
	print_debug("Examining")

func execute_a() -> void:
	super()
	print("Rotating Left")
	reactor.turn("left")


func execute_b() -> void:
	super()
	print("Rotating Left")
	reactor.turn("left")
