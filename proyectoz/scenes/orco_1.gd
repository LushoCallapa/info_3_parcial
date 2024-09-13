extends CharacterBody2D

@export var target: Node2D = null
@export var max_speed = 50
@onready var navigation: NavigationAgent2D = $NavigationAgent2D

func setup():
	await get_tree().physics_frame
	if target:
		navigation.target_position = target.global_position

func _ready() -> void:
	call_deferred("setup")
	print(navigation.get_current_navigation_path())
	
func _physics_process(delta: float) -> void:
	if target:
		#print(navigation.target_position,"--",target.global_position)
		navigation.target_position = target.global_position
	if navigation.is_navigation_finished():
		return
	
	var nex_path_position = navigation.get_next_path_position()
	
	velocity = global_position.direction_to(nex_path_position) * max_speed
	
	move_and_slide()
