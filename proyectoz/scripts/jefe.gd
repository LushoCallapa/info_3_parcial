extends CharacterBody2D


@export var target: Node2D = null
@export var max_speed = 50
@export var body: CharacterBody2D
@onready var navigation: NavigationAgent2D = $NavigationAgent2D
@onready var animation_tree = $AnimationTree
@onready var state_machine = $AnimationTree.get("parameters/playback")

enum {
	PAUSE,
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
	animation_tree.set("parameters/Idle/blend_position", input_vector)
	animation_tree.set("parameters/DamageReceive/blend_position", input_vector)
	animation_tree.set("parameters/Walk/blend_position", input_vector)
	animation_tree.set("parameters/Attack/blend_position", input_vector)
	

func _ready() -> void:
	call_deferred("setup")
	print(navigation.get_current_navigation_path())
	
func _physics_process(delta: float) -> void:
	if not body:
		attack_anim_finished()
		state = PAUSE
	match state:
		MOVE:
			move_state(delta)
		ATTACK:
			attack_state(delta)

func move_state(delta):
	if target:
		navigation.target_position = target.global_position
	else:
		state = PAUSE
	if navigation.is_navigation_finished():
		return
	set_animations(velocity)
	state_machine.travel("Walk")
	var nex_path_position = navigation.get_next_path_position()
	
	velocity = global_position.direction_to(nex_path_position) * max_speed
	
	move_and_slide()

func attack_state(delta):
	state_machine.travel("Attack")

func attack_anim_finished():
	state = MOVE
	if not body:
		state = PAUSE
	
func _on_detection_area_area_entered(area: Area2D) -> void:
	body.damage = 20
	print("Hola")
	state = ATTACK


func _on_detection_area_area_exited(area: Area2D) -> void:
	print("Adios")
	state = MOVE
	if not body:
		state = PAUSE


func _on_hit_box_area_entered(area: Area2D) -> void:
	body.damage = 20
