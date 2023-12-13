extends Node2D  # or KinematicBody2D/RigidBody2D if using physics

var speed = 1800 # Bullet speed
var direction = Vector2.ZERO  # Direction the bullet will move in\

func _process(delta):
	position += direction.normalized() * speed * delta
