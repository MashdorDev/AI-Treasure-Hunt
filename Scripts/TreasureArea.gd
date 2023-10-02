extends Area2D  # Make sure the script is attached to an Area2D node

func _ready():
	self.area_entered.connect(_on_TreasureArea_area_entered)  # New syntax for connecting signals

func _on_TreasureArea_area_entered(area: Area2D) -> void:
	if area.name == "Player":
		self.queue_free()  # Remove the treasure when the player collides with it
