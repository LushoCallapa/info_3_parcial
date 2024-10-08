extends CharacterBody2D

class_name Orco1

signal healthChanged
signal deathCount

@export var target: Node2D = null
@export var max_speed = 50
@export var body: CharacterBody2D
@onready var navigation: NavigationAgent2D = $NavigationAgent2D
@onready var animation_tree = $AnimationTree
@onready var state_machine = $AnimationTree.get("parameters/playback")

@export var maxHealth = 100
@export var currentHealth: int = maxHealth

enum {
	MOVE,
	PAUSE,
	ATTACK,
	HURT,
	DEATH,
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
	animation_tree.set("parameters/dead/blend_position", input_vector)
	

func _ready() -> void:
	call_deferred("setup")
	#print(navigation.get_current_navigation_path())
	
func _physics_process(delta: float) -> void:
	if not body:
		attack_anim_finished()
		state = PAUSE
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
	if target:
		navigation.target_position = target.global_position
	if navigation.is_navigation_finished():
		return
	set_animations(velocity)
	state_machine.travel("run")
	var nex_path_position = navigation.get_next_path_position()
	
	velocity = global_position.direction_to(nex_path_position) * max_speed
	
	move_and_slide()
	
func receive_damage(amount: int):
	currentHealth -= amount  # Reducir la salud
	#print(currentHealth)
	emit_signal("healthChanged", currentHealth)
	healthChanged.emit()

	# Si la salud llega a cero, el personaje muere
	if currentHealth <= 0:
		currentHealth = 0
		state = DEATH
	else:
		# Si no muere, activar la animación de daño
		state = HURT
	
func hurt_state(delta):
	state_machine.travel("hurt")
	velocity = Vector2.ZERO
	
func death_state(delta):
	state_machine.travel("dead")

func attack_state(delta):
	state_machine.travel("attack")

func attack_anim_finished():
	state = MOVE
	if not body:
		state = PAUSE
		
func attack_hurt_finished():
	state = MOVE
	
func death_animation_finish():
	queue_free()
	deathCount.emit()
	
func _on_area_2d_area_entered(area: Area2D) -> void:
	body.damage = 10
	if currentHealth > 0:
		state = ATTACK

func _on_hurt_box_area_entered(area: Area2D) -> void:
	receive_damage(10)


func _on_detection_area_area_exited(area: Area2D) -> void:
	state = MOVE
	if not body:
		state = PAUSE
