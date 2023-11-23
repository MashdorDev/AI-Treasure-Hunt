extends Area2D

func _ready():
	print_debug("Treasure ready")
	self.area_entered.connect(_on_Treasure_area_entered)

func _on_Treasure_area_entered(area: Area2D) -> void:
	if area.name == "Player":
		print_debug("Weapon collected")
		self.queue_free()
