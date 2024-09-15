extends RigidBody2D

@export var target: Vector2
var speed = 100
@export var direction: Vector2



func _physics_process(delta):
	print(direction)
	linear_velocity = direction * speed
	var distance = global_position.distance_to(target)
	if distance < 1:
		queue_free()
