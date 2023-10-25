extends Node2D

var speed = 400  # Speed in pixels per second
var current_velocity = Vector2.ZERO  # Added this line to store the player's current velocity

func _ready():
	call_deferred("set_name", "Player")  # Defer renaming the node to the next frame

func _process(delta):
	var mouse_pos = get_global_mouse_position()
	var to_mouse_vector = mouse_pos - global_position

	# Make the player face the mouse
	look_at(mouse_pos * -1)

	# Move the player towards the mouse when the left mouse button is pressed
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if to_mouse_vector.length() > 10:
			to_mouse_vector = to_mouse_vector.normalized() * speed
			global_position += to_mouse_vector * delta
			current_velocity = to_mouse_vector  # Update the current_velocity variable
		else:
			current_velocity = Vector2.ZERO  # Reset the velocity if the player is not moving
