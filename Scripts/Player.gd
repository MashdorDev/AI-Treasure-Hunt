extends Node2D

var speed = 400
var current_velocity = Vector2.ZERO
var movement_smoothness = 0.1
var has_weapon = false  # Variable to track if the player has the weapon
var PlayerMp5Sprite = "res://Assets/Player/Player_Mp5.png"
var shot_speed = 200  # Increased speed of the shot
var shot_lifetime = 5.0  # Time in seconds before the shot is removed
var bullet_scene = "res://Scenes/Bullet.tscn"
var can_shoot = true  # Flag to control shooting cooldown
var shoot_cooldown = 0.09  # Cooldown time in seconds between shots



func _ready():
	call_deferred("set_name", "Player")

func _process(delta):
	var mouse_pos = get_global_mouse_position()
	var to_mouse_vector = mouse_pos - global_position

	look_at(mouse_pos)
	handle_movement(to_mouse_vector, delta)

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) and has_weapon:
		shoot()
		
	for child in get_children():
		if child is Line2D:
			_process_shot(child, delta)

func handle_movement(to_mouse_vector, delta):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if to_mouse_vector.length() > 10:
			var target_velocity = to_mouse_vector.normalized() * speed
			current_velocity = current_velocity.lerp(target_velocity, movement_smoothness)
		else:
			current_velocity = Vector2.ZERO
	else:
		current_velocity = current_velocity.lerp(Vector2.ZERO, movement_smoothness)

	global_position += current_velocity * delta

func change_sprite():
	var sprite = $Sprite2D  # Adjust according to your node structure
	sprite.texture = load(PlayerMp5Sprite)
	has_weapon = true  # Player now has the weapon


func shoot():
	if not can_shoot:
		return  # Exit the function early if still in cooldown

	can_shoot = false  # Start cooldown
	var bullet_scene_resource = load(bullet_scene)  # Load the scene resource
	if bullet_scene_resource is PackedScene:  # Check if it's a PackedScene
		var bullet_instance = bullet_scene_resource.instantiate() as Node2D
		bullet_instance.position = global_position
		bullet_instance.rotation = rotation

		# Set the bullet's direction
		var mouse_pos = get_global_mouse_position()
		bullet_instance.direction = (mouse_pos - bullet_instance.position).normalized()

		get_parent().add_child(bullet_instance)

	# Wait for shoot_cooldown before reactivating shooting
	await get_tree().create_timer(shoot_cooldown).timeout
	can_shoot = true



func create_shot() -> Line2D:
	var shot = Line2D.new()
	shot.width = 3
	shot.default_color = Color(1, 1, 0)  # Yellow color
	shot.points = [Vector2.ZERO, Vector2(0, -10)]  # Length of the shot

	shot.global_position = global_position + global_transform.y.normalized() * get_player_radius()
	shot.global_rotation = rotation



	shot.set_process(true)
	return shot

func _process_shot(shot: Line2D, delta: float) -> void:
	shot.global_position += shot.transform.x * shot_speed * delta

	# Estimated size of the shot for bounds checking
	var shot_size = Vector2(10, 10)  # Adjust as needed

	# Check if shot is outside of camera's view
	if not get_viewport().get_visible_rect().intersects(Rect2(shot.global_position - shot_size / 2, shot_size)):
		shot.queue_free()

func get_player_radius() -> float:
	# Assuming your player's collision shape is a CircleShape2D
	var collision_shape = $CollisionShape2D.shape
	if collision_shape is CircleShape2D:
		return collision_shape.radius
	return 0
