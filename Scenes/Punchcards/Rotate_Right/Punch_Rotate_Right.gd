extends PunchCard

func execute() -> void:
	super()
	print("Rotating Right")
	reactor.turn("right")


func execute_a() -> void:
	super()
	reactor.read_scripture("hopeful")


func execute_b() -> void:
	super()
	print("Rotating Right")
	reactor.turn("right")
