extends Node2D

var speed: float = 220.0
var prediction_time: float = 0.5
var player: Node2D
var player_velocity: Vector2
var end_game_triggered: bool = false
var current_velocity: Vector2 = Vector2()
var is_seeking: bool = true

func _ready():
	print_debug("Hello From Enemy")
	player = get_node("../Player")  # Ensure this correctly references the player node
	self.area_entered.connect(_on_body_entered)  # Connect collision signal
	set_process(true)

func _physics_process(delta):
	if player == null or end_game_triggered or not is_seeking:
		return

	player_velocity = player.get("current_velocity")
	var predicted_position = player.global_position + player_velocity * prediction_time
	seek(predicted_position, delta)

func seek(target_position: Vector2, delta: float) -> void:
	var distance_to_player = global_position.distance_to(target_position)
	var desired_velocity: Vector2 = (target_position - global_position).normalized() * speed

	# Adjust the speed based on distance to the player
	if distance_to_player < 50:  # This is the slowing radius, adjust as needed
		var slowing_factor = distance_to_player / 50  # Slow down as it gets closer
		desired_velocity *= slowing_factor

	# Apply a steering force towards the desired velocity
	var steering: Vector2 = (desired_velocity - current_velocity).normalized() * speed
	current_velocity += steering * delta

	# Update the position
	global_position += current_velocity * delta


func _on_body_entered(body: Node) -> void:
	if body == player:
		print("collided with player")
		player.queue_free()  # Delete the player on collision
		trigger_end_game()

func trigger_end_game() -> void:
	end_game_triggered = true
	# Add any end game logic here
