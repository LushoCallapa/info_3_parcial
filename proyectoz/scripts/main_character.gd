extends CharacterBody2D

@onready var animation_tree = $AnimationTree
@onready var state_machine = $AnimationTree.get("parameters/playback")
@export var body: CharacterBody2D

@export var health = 100

const ACCELERATION = 500
const FRICTION = 500
const MAX_SPEED = 50
const RUN_SPEED_MULTIPLIER = 1.7  # Multiplicador de velocidad cuando se corre

# estados del player
enum {
	MOVE,
	ATTACK
}

# variable de estado actual
var state = MOVE
var is_running = false  # Variable para indicar si está corriendo

func set_animations(input_vector):
	animation_tree.set("parameters/Idle/blend_position", input_vector)
	animation_tree.set("parameters/Walk/blend_position", input_vector)
	animation_tree.set("parameters/Run/blend_position", input_vector)
	animation_tree.set("parameters/Attack/blend_position", input_vector)
	animation_tree.set("parameters/Walk_Attack/blend_position", input_vector)
	animation_tree.set("parameters/Run_Attack/blend_position", input_vector)
	animation_tree.set("parameters/Hurt/blend_position", input_vector)
	animation_tree.set("parameters/Death/blend_position", input_vector)

func _physics_process(delta: float) -> void:
	match state:
		MOVE:
			move_state(delta)
		ATTACK:
			attack_state(delta)

func move_state(delta):
	var input_vector = Vector2.ZERO
	
	# Verifica si se están usando las teclas normales o las de correr
	if Input.is_action_pressed("RunUp"):
		input_vector.y = -1
	elif Input.is_action_pressed("RunDown"):
		input_vector.y = 1
	elif Input.is_action_pressed("up"):
		input_vector.y = -1
	elif Input.is_action_pressed("down"):
		input_vector.y = 1

	if Input.is_action_pressed("RunRight"):
		input_vector.x = 1
	elif Input.is_action_pressed("RunLeft"):
		input_vector.x = -1
	elif Input.is_action_pressed("right"):
		input_vector.x = 1
	elif Input.is_action_pressed("left"):
		input_vector.x = -1

	input_vector = input_vector.normalized()

	if input_vector != Vector2.ZERO:
		set_animations(input_vector)
		
		# Si se están usando las teclas Run, el personaje corre
		if Input.is_action_pressed("RunUp") or Input.is_action_pressed("RunDown") or Input.is_action_pressed("RunRight") or Input.is_action_pressed("RunLeft"):
			is_running = true
			state_machine.travel("Run")
			velocity = velocity.move_toward(input_vector * MAX_SPEED * RUN_SPEED_MULTIPLIER, ACCELERATION * delta)
		else:
			is_running = false
			state_machine.travel("Walk")
			velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		set_animations(input_vector)
		state_machine.travel("Idle")
		is_running = false
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
	move_and_slide()

	# Transición a ATTACK si se presiona el botón de ataque
	if Input.is_action_just_pressed("NormalAttack"):
		state = ATTACK

func attack_state(delta):
	velocity = Vector2.ZERO  # Detiene el movimiento durante el ataque
	
	# Si está corriendo, usa la animación de Run_Attack, de lo contrario, usa Walk_Attack
	if is_running:
		state_machine.travel("Run_Attack")
	else:
		state_machine.travel("Walk_Attack")
		
	state = MOVE

	# Transición de vuelta a MOVE al finalizar la animación de ataque
	#if animation_tree.is_animation_finished():
		#state = MOVE

func attack_anim_finished():
	state = MOVE
