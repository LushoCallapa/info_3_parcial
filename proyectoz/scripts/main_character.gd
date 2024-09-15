extends CharacterBody2D

class_name MainCharacter

signal healthChanged

@onready var animation_tree = $AnimationTree
@onready var state_machine = $AnimationTree.get("parameters/playback")
@export var body: CharacterBody2D
@export var damage = 10
@export var maxHealth = 150
@export var currentHealth: int = maxHealth

const ACCELERATION = 500
const FRICTION = 500
const MAX_SPEED = 50
const RUN_SPEED_MULTIPLIER = 1.7 

enum {
	MOVE,
	ATTACK,
	HURT,
	DEATH
}

var bullet_scene
var state = MOVE
var is_running = false
func _ready() -> void:
	bullet_scene = preload("res://scenes/bullet.tscn")
	
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

	if input_vector != Vector2.ZERO:
		set_animations(input_vector)
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

	if Input.is_action_just_pressed("NormalAttack"):
		#state_machine.travel("Attack")
		state = ATTACK
		
	if Input.is_action_just_pressed("SpecialAttack"):
		var bullet_instance = bullet_scene.instantiate()
		get_parent().add_child(bullet_instance)
		bullet_instance.global_position = global_position
		var mouse_position = get_global_mouse_position()
		#print(global_position  ,mouse_position)
		var direction = (mouse_position - global_position).normalized()
		bullet_instance.target = mouse_position
		bullet_instance.direction = direction
		state = ATTACK

func attack_state(delta):
	velocity = Vector2.ZERO
	
	if is_running:
		state_machine.travel("Run_Attack")
	else:
		state_machine.travel("Walk_Attack")
		
	state = MOVE

func attack_anim_finished():
	state = MOVE
	
func attack_hurt_finished():
	state = MOVE

func receive_damage(amount: int):
	currentHealth -= amount
	print(currentHealth)
	emit_signal("healthChanged", currentHealth)
	healthChanged.emit()

	if currentHealth <= 0:
		currentHealth = 0
		state = DEATH
	else:
		state = HURT

func death_state(delta):
	state_machine.travel("Death")

func hurt_state(delta):
	#velocity = Vector2.ZERO  # Detiene el movimiento durante el daño
	state_machine.travel("Hurt")

func death_animation_finish():
	queue_free()
	
func _on_hurt_box_area_entered(area: Area2D) -> void:
	print("area")
	receive_damage(damage)
