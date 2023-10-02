extends Sprite2D  

func _ready():
	print_debug("Tresaure Detected")
	pass

func _on_Player_body_entered(body):
	if body.name == "Player":
		print_debug("Player Detected")
		queue_free()  # Remove the treasure when the player collides with it
