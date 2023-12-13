extends Node2D

# Constants and variables
var speed: float = 220.0
var prediction_time: float = 0.5
var Bullet: Area2D
var player: Node2D
var player_velocity: Vector2
var end_game_triggered: bool = false
var current_velocity: Vector2 = Vector2()

# Enhanced state definitions
enum States { PATROL, SEEK, EVADE }
var state = States.PATROL

# Additional variables for new states
var patrol_points: Array = []  
var current_patrol_index: int = 0
var patrol_threshold: float = 10.0
var number_of_patrol_points: int = 5  # Number of patrol points to generate

func _ready():
	player = get_node_or_null("../Player")  # Safe access
	if player == null:
		print("Player node not found.")
	self.area_entered.connect(_on_body_entered)
	generate_patrol_points()

func generate_patrol_points():
	patrol_points.clear()
	var camera_rect = get_viewport().get_visible_rect()
	for i in range(number_of_patrol_points):
		var point = Vector2(
			randf_range(camera_rect.position.x, camera_rect.end.x),
			randf_range(camera_rect.position.y, camera_rect.end.y)
		)
		patrol_points.append(point)

func _physics_process(delta):
	if end_game_triggered:
		return

	decide_state()
	process_state(delta)

# Decision Tree Logic
func decide_state() -> void:
	if end_game_triggered:
		return
	if player != null:
		if player_has_gun() and is_player_close():
			state = States.EVADE
		elif is_player_visible():
			state = States.SEEK
		else:
			state = States.PATROL
	else:
		state = States.PATROL

func player_has_gun() -> bool:
	return player.has_method("is_holding_gun") and player.is_holding_gun()

func is_player_close() -> bool:
	var distance = global_position.distance_to(player.global_position)
	return distance < 100 # Threshold for close distance

func is_player_visible() -> bool:
	var distance = global_position.distance_to(player.global_position)
	return distance < 300 # Threshold for visibility

func process_state(delta):
	match state:
		States.PATROL:
			patrol(delta)
		States.SEEK:
			seek(player.global_position + player_velocity * prediction_time, delta)
		States.EVADE:
			evade(player.global_position + player_velocity * prediction_time, delta)

func patrol(delta: float):
	if patrol_points.size() == 0:
		generate_patrol_points()
	var target_position = patrol_points[current_patrol_index]
	var distance_to_target = global_position.distance_to(target_position)

	if distance_to_target < patrol_threshold:
		current_patrol_index = (current_patrol_index + 1) % patrol_points.size()
		target_position = patrol_points[current_patrol_index]

	var desired_velocity: Vector2 = (target_position - global_position).normalized() * speed
	current_velocity = desired_velocity
	global_position += current_velocity * delta

func seek(target_position: Vector2, delta: float) -> void:
	var distance_to_player = global_position.distance_to(target_position)
	var desired_velocity: Vector2 = (target_position - global_position).normalized() * speed

	if distance_to_player < 50:
		var slowing_factor = distance_to_player / 50
		desired_velocity *= slowing_factor

	var steering: Vector2 = (desired_velocity - current_velocity).normalized() * speed
	current_velocity += steering * delta
	global_position += current_velocity * delta

func evade(target_position: Vector2, delta: float) -> void:
	var direction_away_from_player = (global_position - target_position).normalized()
	var evade_velocity = direction_away_from_player * speed

	current_velocity = evade_velocity
	global_position += current_velocity * delta

func _on_body_entered(body: Node) -> void:
	if body.name == "Bullet":
		end_game_triggered = true
		self.queue_free()
	
	if body == player:
		print("collided with player")
		player.queue_free()
		end_game_triggered = true
		state = States.PATROL
		generate_patrol_points()

func trigger_end_game() -> void:
	end_game_triggered = true
