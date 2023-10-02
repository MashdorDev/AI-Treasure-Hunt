extends Node2D

var speed = 400  # Speed in pixels per second

func _ready():
	pass

func _process(delta):
	var mouse_pos = get_global_mouse_position()
	var to_mouse_vector = mouse_pos - global_position
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if to_mouse_vector.length() > 10:
			to_mouse_vector = to_mouse_vector.normalized() * speed
			global_position += to_mouse_vector * delta
