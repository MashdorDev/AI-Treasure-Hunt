extends Area2D

func _ready():
	print_debug("Weapon ready")
	self.area_entered.connect(_on_Player_area_entered)

func _on_Player_area_entered(area: Area2D) -> void:
	if area.name == "Player":
		print_debug("Weapon collected")

		# Access the player and call the change_sprite method
		if area.has_method("change_sprite"):
			area.change_sprite()

		self.queue_free()
