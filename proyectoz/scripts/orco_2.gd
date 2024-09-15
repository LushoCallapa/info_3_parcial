extends CharacterBody2D


@export var target: Node2D = null
@export var max_speed = 50
@export var body: CharacterBody2D
@onready var navigation: NavigationAgent2D = $NavigationAgent2D
@onready var animation_tree = $AnimationTree
@onready var state_machine = $AnimationTree.get("parameters/playback")

@export var maxHealth = 100
@export var currentHealth: int = maxHealth
var bullet_scene
enum {
	PAUSE,
	ATTACK,
	HURT,
	DEATH,
}

# variable de estado actual

var state = ATTACK

func _ready() -> void:
	bullet_scene = preload("res://scenes/bullet_enemy.tscn")

func setup():
	await get_tree().physics_frame

func set_animations(input_vector):
	animation_tree.set("parameters/idle/blend_position", input_vector)
	animation_tree.set("parameters/hurt/blend_position", input_vector)
	animation_tree.set("parameters/attack/blend_position", input_vector)
	animation_tree.set("parameters/dead/blend_position", input_vector)
	
	
func _physics_process(delta: float) -> void:
	if not body:
		attack_anim_finished()
		state = PAUSE
	else:
		set_animations(body.global_position)
	match state:
		ATTACK:
			attack_state(delta)
		HURT:
			hurt_state(delta)
		DEATH:
			death_state(delta)
		PAUSE:
			pause_state(delta)
		
func pause_state(delta):

	state_machine.travel("idle")
	
func receive_damage(amount: int):
	currentHealth -= amount  # Reducir la salud
	#print(currentHealth)

	# Si la salud llega a cero, el personaje muere
	if currentHealth <= 0:
		currentHealth = 0
		state = DEATH
	else:
		# Si no muere, activar la animación de daño
		state = HURT
	
func hurt_state(delta):
	state_machine.travel("hurt")
	
func death_state(delta):
	state_machine.travel("dead")

func attack_state(delta):
	state_machine.travel("attack")

func attack_anim_finished():
	if not body:
		state = PAUSE
		return
	var bullet_instance = bullet_scene.instantiate()
	get_parent().add_child(bullet_instance)
	bullet_instance.global_position = global_position
	var final_position = target.global_position
	var direction = (final_position - global_position).normalized()
	bullet_instance.target = final_position
	bullet_instance.direction = direction
	get_node("next_atack").start()
	state = PAUSE

		
func attack_hurt_finished():
	get_node("next_atack").start()
	state = PAUSE
	
	
func death_animation_finish():
	queue_free()
	

func _on_next_atack_timeout() -> void:
	#print(state)
	get_node("next_atack").stop()
	if currentHealth > 0:
		state = ATTACK


func _on_hurt_box_area_entered(area: Area2D) -> void:
	receive_damage(10) # Replace with function body.
