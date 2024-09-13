extends ParallaxLayer

@export var space_speed = -150.0

func _process(delta: float) -> void:
	self.motion_offset.x += space_speed * delta
