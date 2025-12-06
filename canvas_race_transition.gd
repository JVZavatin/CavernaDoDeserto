extends CanvasLayer

@onready var timer = $TransitionTimer

@onready var background = $BlackBackground
@onready var Sprite3 = $"CenterContainer/3"
@onready var Sprite2 = $"CenterContainer/2"
@onready var Sprite1 = $"CenterContainer/1"

#@onready var animation_tween = create_tween()

var number_on_screen = 0

func _ready():
	pass

func _process(_delta):
	if (is_instance_valid(timer) && !timer.is_stopped()):
		if Input.is_anything_pressed():
			get_viewport().set_input_as_handled()

func start_transition():
	background.show()
	if (!Sprite3.visible && !Sprite2.visible && !Sprite1.visible):
		start_timer()
	pass

func start_timer():
	number_on_screen = 4
	timer.start()

func _on_transition_timer_timeout() -> void:
	Sprite3.hide()
	Sprite2.hide()
	Sprite1.hide()
	match number_on_screen:
		4:
			number_on_screen -= 1
		3:
			Sprite3.show()
			fade_in(Sprite3)
			number_on_screen -= 1
		2:
			Sprite2.show()
			fade_in(Sprite2)
			number_on_screen -= 1
		1:
			Sprite1.show()
			fade_in(Sprite1)
			number_on_screen -= 1
		_: 
			number_on_screen = 4
			background.hide()
			timer.stop()


func fade_out(obj):
	obj.modulate.a = 1.0
	var animation_tween = create_tween()
	animation_tween.tween_property(obj, "modulate:a", 0.0, 1.0)
	
func fade_in(obj):
	obj.modulate.a = 0.0
	var animation_tween = create_tween()
	animation_tween.tween_property(obj, "modulate:a", 1.0, 1.0)
