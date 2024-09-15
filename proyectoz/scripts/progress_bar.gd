extends TextureProgressBar

@export var mainCharacter: MainCharacter

func _ready() -> void:
	mainCharacter.healthChanged.connect(update)
	update()

func update():
	value = mainCharacter.currentHealth * 100 / mainCharacter.maxHealth
