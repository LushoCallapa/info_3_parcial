extends TextureProgressBar

@export var orco1: Orco1

func _ready() -> void:
	orco1.healthChanged.connect(update)
	update()

func update():
	value = orco1.currentHealth * 100 / orco1.maxHealth
