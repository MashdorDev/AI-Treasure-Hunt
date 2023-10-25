extends Node2D

var speed: float = 10.0
var player: Node2D
var end_game_triggered: bool = false
var current_velocity: Vector2 = Vector2()
var is_seeking: bool = true

func _ready():
	print_debug("Hello From Enemy")
	player = get_node("../Player")
	$Area2D.connect("body_entered", Callable(self, "_on_body_entered"))

func _physics_process(delta):
	if player == null or end_game_triggered or not is_seeking:
		return
	seek(player.global_position, delta)

func seek(target_position: Vector2, delta: float) -> void:
	var distance_to_player = global_position.distance_to(target_position)

	if distance_to_player <= 20:
		current_velocity = Vector2.ZERO
		global_position = target_position  # Snap to the exact position
		_on_body_entered(player)
		is_seeking = false  # Stop seeking
		return

	# Dynamically adjust speed based on distance to player
	var slowing_radius: float = 20.0  # Radius within which to start slowing down
	var adjusted_speed: float = speed * (distance_to_player / slowing_radius)
	if adjusted_speed < 10.0:  # Minimum speed threshold
		adjusted_speed = 10.0

	var desired_velocity: Vector2 = (target_position - global_position).normalized() * adjusted_speed
	var steering: Vector2 = desired_velocity - current_velocity
	current_velocity += steering * delta
	global_position += current_velocity * delta


func _on_body_entered(body: Node) -> void:
	print("Body entered: ", body.name)
	if body == player:
		print("collided with player")
		player.queue_free()
		trigger_end_game()

func trigger_end_game() -> void:
	end_game_triggered = true
	# Implement your end game sequence here
