extends Node2D

# Declarar las listas para Orco1 y Orco2
var orcos1: Array = []

func _ready():
	orcos1.append(get_node("Orco1"))
	orcos1.append(get_node("Orco2"))
	orcos1.append(get_node("Orco3"))
	orcos1.append(get_node("Orco4"))
	orcos1.append(get_node("Orco5"))
	orcos1.append(get_node("Orco6"))
	
func _process(delta: float) -> void:
	orcos1 = orcos1.filter(is_instance_valid)

	if orcos1.size() == 0:
		change_level()
	
func change_level():
	get_tree().change_scene_to_file("res://scenes/next_level.tscn")
