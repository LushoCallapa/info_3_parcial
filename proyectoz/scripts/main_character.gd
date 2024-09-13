extends CharacterBody2D

#var movespeed = 10

@onready var animation_tree = $AnimationTree
@onready var state_machine = $AnimationTree.get("parameters/playback")
@export var body: CharacterBody2D

#func _physics_process(delta: float) -> void:
	#var motion = Vector2()
	#
	#if Input.is_action_just_pressed("up"):
		#motion.y -=1
	#if Input.is_action_just_pressed("down"):
		#motion.y +=1
	#if Input.is_action_just_pressed("right"):
		#motion.x +=1
	#if Input.is_action_just_pressed("left"):
		#motion.x -=1
		#
	#motion = motion.normalized()
	#motion = move_and_collide(motion * movespeed)
	#look_at(get_global_mouse_position())

@export var health = 100

const ACCELERATION = 500
const FRICTION = 500
const MAX_SPEED = 50

# estados del player
enum {
	MOVE,
	ROLL,
	ATTACK
}

# variable de estado actual
var state = MOVE

func set_animations(input_vector):
	animation_tree.set("parameters/Idle/blend_position", input_vector)
	animation_tree.set("parameters/Walk/blend_position", input_vector)
	animation_tree.set("parameters/Run/blend_position", input_vector)
	animation_tree.set("parameters/Attack/blend_position", input_vector)

func _physics_process(delta: float) -> void:
	match state:
		MOVE:
			move_state(delta)
		ROLL:
			pass
		ATTACK:
			attack_state(delta)
	
func move_state(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_axis("left", "right")
	input_vector.y = Input.get_axis("up", "down")
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		set_animations(input_vector)
		state_machine.travel("Walk")
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
		print(input_vector.normalized())
	else:
		set_animations(input_vector)
		state_machine.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
		
	#look_at(get_global_mouse_position())
	move_and_slide()
	
	if Input.is_action_just_pressed("NormalAttack"):
		# transicion a ATTACK
		state = ATTACK

func attack_state(delta):
	velocity = Vector2.ZERO
	state_machine.travel("Attack")

func attack_anim_finished():
	state = MOVE
