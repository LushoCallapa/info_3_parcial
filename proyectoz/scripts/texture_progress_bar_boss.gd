extends TextureProgressBar

@export var Jefe: Jefe

func _ready() -> void:
	Jefe.healthChanged.connect(update)
	update()

func update():
	value = Jefe.currentHealth * 100 / Jefe.maxHealth
