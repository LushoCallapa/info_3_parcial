extends RigidBody2D

@export var target: Node2D = null
@export var max_speed = 130
@export var body: CharacterBody2D
@onready var navigation: NavigationAgent2D = $NavigationAgent2D
enum {
	MOVE,
	PAUSE
}
var state = MOVE
func setup():
	await get_tree().physics_frame
	if body:
		if target:
			navigation.target_position = target.global_position
func _ready() -> void:
	call_deferred("setup")
	
func _physics_process(delta):
	if not body:
		state = PAUSE
	match state:
		MOVE:
			move_state(delta)
		

func move_state(delta):
	if target:
		navigation.target_position = target.global_position
	if navigation.is_navigation_finished():
		return
	var nex_path_position = navigation.get_next_path_position()
		
	linear_velocity = global_position.direction_to(nex_path_position) * max_speed

func _on_hit_box_area_entered(area: Area2D) -> void:
	queue_free()
