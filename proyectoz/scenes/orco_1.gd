extends CharacterBody2D

@export var target: Node2D = null
@export var max_speed = 50
@onready var navigation: NavigationAgent2D = $NavigationAgent2D
@onready var animation_tree = $AnimationTree
@onready var state_machine = $AnimationTree.get("parameters/playback")

enum {
	MOVE,
	ROLL,
	ATTACK
}

# variable de estado actual
var state = MOVE
func setup():
	await get_tree().physics_frame
	if target:
		navigation.target_position = target.global_position

func set_animations(input_vector):
	animation_tree.set("parameters/idle/blend_position", input_vector)
	animation_tree.set("parameters/hurt/blend_position", input_vector)
	animation_tree.set("parameters/run/blend_position", input_vector)
	animation_tree.set("parameters/attack/blend_position", input_vector)
	

func _ready() -> void:
	call_deferred("setup")
	print(navigation.get_current_navigation_path())
	
func _physics_process(delta: float) -> void:
	match state:
		MOVE:
			move_state(delta)
		ROLL:
			pass
		ATTACK:
			attack_state(delta)

func move_state(delta):
	if target:
		navigation.target_position = target.global_position
	if navigation.is_navigation_finished():
		return
	set_animations(velocity)
	state_machine.travel("run")
	var nex_path_position = navigation.get_next_path_position()
	
	velocity = global_position.direction_to(nex_path_position) * max_speed
	
	move_and_slide()

func attack_state(delta):
	state_machine.travel("attack")

func attack_anim_finished():
	state = MOVE
	
func _on_area_2d_area_entered(area: Area2D) -> void:
	state = ATTACK

	
