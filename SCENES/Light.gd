extends PointLight2D

var fire_time: float = 100.0
var max_scale: Vector2 = Vector2(2, 2)
var min_scale: Vector2 = Vector2(0.2, 0.2)
var max_time: float = 100.0

func _process(delta: float) -> void:
	fire_time = clamp(fire_time, 0, max_time)
	var current_scale = min_scale.lerp(max_scale, fire_time / max_time)
	self.scale = current_scale
