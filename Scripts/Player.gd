extends Node2D

var speed = 400  # Speed in pixels per second
var current_velocity = Vector2.ZERO  # Store the player's current velocity
var movement_smoothness = 0.1  # Adjust for smoother movement transitions

func _ready():
	call_deferred("set_name", "Player")

func _process(delta):
	var mouse_pos = get_global_mouse_position()
	var to_mouse_vector = mouse_pos - global_position

	# Make the player face the mouse
	look_at(mouse_pos)

	# Move the player towards the mouse when the left mouse button is pressed
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if to_mouse_vector.length() > 10:
			var target_velocity = to_mouse_vector.normalized() * speed
			current_velocity = current_velocity.lerp(target_velocity, movement_smoothness)
		else:
			current_velocity = Vector2.ZERO
	else:
		current_velocity = current_velocity.lerp(Vector2.ZERO, movement_smoothness)

	global_position += current_velocity * delta
