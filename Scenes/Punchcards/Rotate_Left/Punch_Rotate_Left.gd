extends PunchCard

func execute() -> void:
	super()
	print("Rotating Left")
	reactor.turn("left")


func execute_a() -> void:
	super()
	reactor.read_scripture("scary")


func execute_b() -> void:
	super()
	print("Rotating Left")
	reactor.turn("left")
