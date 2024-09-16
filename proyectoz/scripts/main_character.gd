extends CharacterBody2D

class_name MainCharacter

signal healthChanged
signal is_death
signal is_hurt

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
var input_vector_aux = Vector2.ZERO
var bullet_scene
var state = MOVE
var is_running = false

func _ready() -> void:
	
	input_vector_aux.x = 0
	input_vector_aux.y = -1
	input_vector_aux = input_vector_aux.normalized()
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

func receive_damage(amount: int):

	currentHealth-= amount
	#print(currentHealth)
	emit_signal("healthChanged", currentHealth)
	healthChanged.emit()

	if currentHealth <= 0:
		currentHealth = 0
		is_death.emit()
	else:
		is_hurt.emit()

func death_animation_finish():
	queue_free()
	
func _on_hurt_box_area_entered(area: Area2D) -> void:
	#print("area")
	receive_damage(damage)


func _on_player_controller_do_death(input_vector: Variant) -> void:
	set_animations(input_vector)
	state_machine.travel("Death")


func _on_player_controller_do_death_finish() -> void:
	queue_free()
	


func _on_player_controller_do_hurt(input_vector: Variant) -> void:
	set_animations(input_vector)
	state_machine.travel("Hurt")

func _on_player_controller_do_idle(input_vector: Variant) -> void:
	set_animations(input_vector)
	state_machine.travel("Idle")


func _on_player_controller_do_run(input_vector: Variant) -> void:
	set_animations(input_vector)
	state_machine.travel("Run")


func _on_player_controller_do_walk(input_vector: Variant) -> void:
	set_animations(input_vector)
	state_machine.travel("Walk")


func _on_player_controller_do_walk_attack(input_vector: Variant) -> void:
	set_animations(input_vector_aux)
	state_machine.travel("Walk_Attack")


func _on_player_controller_health_changed(health: Variant) -> void:
	receive_damage(health)


func _on_player_controller_do_run_attack(input_vector: Variant) -> void:
	set_animations(input_vector_aux)
	state_machine.travel("Run_Attack")


func _on_is_hurt() -> void:
	pass # Replace with function body.
