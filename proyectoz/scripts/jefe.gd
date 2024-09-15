extends CharacterBody2D

class_name Jefe

signal healthChanged

@export var target: Node2D = null
@export var max_speed = 50
@export var body: CharacterBody2D
@export var damage = 20
@onready var navigation: NavigationAgent2D = $NavigationAgent2D
@onready var animation_tree = $AnimationTree
@onready var state_machine = $AnimationTree.get("parameters/playback")

@export var maxHealth = 1000
@export var currentHealth: int = maxHealth
var bullet_scene
enum {
	PAUSE,
	MOVE,
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
	animation_tree.set("parameters/Idle/blend_position", input_vector)
	animation_tree.set("parameters/DamageReceive/blend_position", input_vector)
	animation_tree.set("parameters/Walk/blend_position", input_vector)
	animation_tree.set("parameters/Attack/blend_position", input_vector)
	animation_tree.set("parameters/death/blend_position", input_vector)
	

func _ready() -> void:
	bullet_scene = preload("res://scenes/bullet_guiado_boss.tscn")
	get_node("bullet_add").start()
	call_deferred("setup")
	
	#print(navigation.get_current_navigation_path())
	
func _physics_process(delta: float) -> void:
	if not body:
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
	else:
		state = PAUSE
	if navigation.is_navigation_finished():
		return
	set_animations(velocity)
	state_machine.travel("Walk")
	var nex_path_position = navigation.get_next_path_position()
	
	velocity = global_position.direction_to(nex_path_position) * max_speed
	
	move_and_slide()
	
func receive_damage(amount: int):
	currentHealth -= amount  # Reducir la salud
	print(currentHealth)
	emit_signal("healthChanged", currentHealth)
	healthChanged.emit()

	# Si la salud llega a cero, el personaje muere
	if currentHealth <= 0:
		currentHealth = 0
		state = DEATH
	else:
		# Si no muere, activar la animación de daño
		state = HURT

func attack_state(delta):
	state_machine.travel("Attack")
	
func hurt_state(delta):
	state_machine.travel("DamageReceive")
	velocity = Vector2.ZERO
	
func death_state(delta):
	state_machine.travel("death")

func death_animation_finish():
	queue_free()
		
#func attack_anim_finished():
	#state = MOVE
	#if not body:
		#state = PAUSE

func attack_hurt_finished():
	state = MOVE
	
func _on_detection_area_area_entered(area: Area2D) -> void:
	body.damage = 10
	#print("Hola")
	if currentHealth > 0:
		state = ATTACK


func _on_detection_area_area_exited(area: Area2D) -> void:
	#print("Adios")
	state = MOVE
	if not body:
		state = PAUSE

func _on_hit_box_area_entered(area: Area2D) -> void:
	body.damage = 10


func _on_hurt_box_area_entered(area: Area2D) -> void:
	receive_damage(damage)


func _on_bullet_add_timeout() -> void:
	if not state == PAUSE:
		if currentHealth > 0:
			var bullet_instance = bullet_scene.instantiate()
			get_parent().add_child(bullet_instance)
			bullet_instance.global_position = global_position
			bullet_instance.target = target
			bullet_instance.body = body
	else:
		get_node("bullet_add").stop()
	
	
