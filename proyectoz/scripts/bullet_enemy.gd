extends RigidBody2D

@export var target: Vector2
var speed = 100
@export var direction: Vector2



func _physics_process(delta):
	
	linear_velocity = direction * speed
	var distance = global_position.distance_to(target)
	#print(distance)
	if distance < 3 or distance > 1800:
		queue_free()


func _on_hit_box_area_entered(area: Area2D) -> void:
	queue_free()
