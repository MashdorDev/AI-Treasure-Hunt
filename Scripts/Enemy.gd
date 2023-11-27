extends Node2D

var speed: float = 220.0
var prediction_time: float = 0.5
var Bullet: Area2D
var player: Node2D
var player_velocity: Vector2
var end_game_triggered: bool = false
var current_velocity: Vector2 = Vector2()
var is_seeking: bool = true


enum States { SEEK, EVADE }
var state = States.SEEK

func _ready():
	print_debug("Hello From Enemy")
	player = get_node_or_null("../Player")  # Use get_node_or_null for safer access
	if player == null:
		print("Player node not found.")
	self.area_entered.connect(_on_body_entered)

func _physics_process(delta):
	if player == null or end_game_triggered:
		return

	check_player_gun_status()

	var player_node = player as Node2D
	var predicted_position = player.global_position + player_velocity * prediction_time

	match state:
		States.SEEK:
			seek(predicted_position, delta)
		States.EVADE:
			evade(predicted_position, delta)

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

# In Enemy.gd
func evade(target_position: Vector2, delta: float) -> void:
	var direction_away_from_player = (global_position - target_position).normalized()
	var evade_velocity = direction_away_from_player * speed

	# You might want to limit the evade distance or add additional logic here

	current_velocity = evade_velocity
	global_position += current_velocity * delta


func _on_body_entered(body: Node) -> void:
	print_debug(body.name)
	
	if body.name == "Bullet":
		print_debug("Bullet detected")
		self.queue_free()
		trigger_end_game()
		# Handle bullet collision logic here
	
	if body == player:
		print("collided with player")
		player.queue_free()  # Delete the player on collision
		trigger_end_game()


func check_player_gun_status():
	if player != null and player.has_method("is_holding_gun"):
		if player.is_holding_gun():
			state = States.EVADE
		else:
			state = States.SEEK
	else:
		state = States.SEEK


func trigger_end_game() -> void:
	end_game_triggered = true
	# Add any end game logic here
