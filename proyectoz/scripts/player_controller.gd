extends Node2D

signal healthChanged(health)

signal do_walk(input_vector)
signal do_run(input_vector)
signal do_SpecialAttack(input_vector)
signal do_NormalAttack(input_vector)
signal do_hurt(input_vector)
signal do_death(input_vector)
signal do_idle(input_vector)
signal do_walk_attack(input_vector)
signal do_Run_Attack(input_vector)
signal do_death_finish()


@export var body: CharacterBody2D
var damage = 10
var maxHealth = 150
var currentHealth: int = maxHealth

const ACCELERATION = 500
const FRICTION = 500
const MAX_SPEED = 50
const RUN_SPEED_MULTIPLIER = 1.7 
var bullet_scene
enum {
	MOVE,
	ATTACK,
	HURT,
	DEATH
}
var input_vector_aux = Vector2.ZERO
var last_vector
var state = MOVE
var is_running = false

func _ready() -> void:
	
	input_vector_aux.x = 0
	input_vector_aux.y = -1
	input_vector_aux = input_vector_aux.normalized()
	bullet_scene = preload("res://scenes/bullet.tscn")

func _physics_process(delta: float) -> void:
	match state:
		MOVE:
			move_state(delta)
		ATTACK:
			attack_state(delta)
		HURT:
			hurt_state(delta)
		DEATH:
			death_state(delta)

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
	last_vector = input_vector
	if input_vector != Vector2.ZERO:
		input_vector_aux = input_vector
	if input_vector != Vector2.ZERO:
		if Input.is_action_pressed("RunUp") or Input.is_action_pressed("RunDown") or Input.is_action_pressed("RunRight") or Input.is_action_pressed("RunLeft"):
			is_running = true
			do_run.emit(input_vector)
			body.velocity = body.velocity.move_toward(input_vector * MAX_SPEED * RUN_SPEED_MULTIPLIER, ACCELERATION * delta)
		else:
			is_running = false
			do_walk.emit(input_vector)
			body.velocity = body.velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		do_idle.emit(input_vector_aux)
		is_running = false
		body.velocity = body.velocity.move_toward(Vector2.ZERO, FRICTION * delta)
		
	
	if Input.is_action_just_pressed("NormalAttack"):
		if currentHealth > 0:
			state = ATTACK
		
	if Input.is_action_just_pressed("SpecialAttack"):
		if currentHealth > 0:
			var bullet_instance = bullet_scene.instantiate()
			get_parent().add_child(bullet_instance)
			bullet_instance.global_position = global_position
			var mouse_position = get_global_mouse_position()
			#print(global_position  ,mouse_position)
			var direction = (mouse_position - global_position).normalized()
			bullet_instance.target = mouse_position
			bullet_instance.direction = direction
			state = ATTACK
			
	last_vector = input_vector
	body.move_and_slide()

	if Input.is_action_just_pressed("NormalAttack"):
		#state_machine.travel("Attack")
		if currentHealth > 0:
			state = ATTACK
		
	if Input.is_action_just_pressed("SpecialAttack"):
			state = ATTACK

func attack_state(delta):
	body.velocity = Vector2.ZERO
	
	if is_running:
		do_Run_Attack.emit(last_vector)
	else:
		do_walk_attack.emit(last_vector)
		
	state = MOVE

func attack_anim_finished():
	state = MOVE
	
func attack_hurt_finished():
	state = MOVE

func receive_damage(amount: int):
	currentHealth -= amount
	healthChanged.emit(currentHealth)

	if currentHealth <= 0:
		currentHealth = 0
		state = DEATH
	else:
		state = HURT

func death_state(delta):
	do_death.emit(input_vector_aux)

func hurt_state(delta):
	body.velocity = Vector2.ZERO  # Detiene el movimiento durante el daño
	do_hurt.emit(input_vector_aux)

func death_animation_finish():
	do_death_finish.emit()
	


func _on_main_character_is_death() -> void:
	state = DEATH


func _on_main_character_is_hurt() -> void:
	state = HURT
