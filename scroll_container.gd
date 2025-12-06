extends ScrollContainer

@export var scroll_speed: float = 100.0

func _process(delta):
	if Input.is_action_pressed("scroll_up"):
		scroll_vertical -= scroll_speed * delta
	if Input.is_action_pressed("scroll_down"):
		scroll_vertical += scroll_speed * delta
