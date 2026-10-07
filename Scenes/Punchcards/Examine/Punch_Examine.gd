extends PunchCard

func execute() -> void:
	super()
	print_debug("Examining")


func execute_a() -> void:
	super()
	print("Rotating Left")
	reactor.talk()


func execute_b() -> void:
	super()
	print("Rotating Left")
	reactor.examine()
