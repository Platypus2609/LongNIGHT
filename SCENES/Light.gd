extends PointLight2D

var fire_time = 100.0
var max_scale = Vector2(2, 2)  # Максимальний масштаб
var min_scale = Vector2(0.2, 0.2)  # Мінімальний масштаб
var max_time = 100  # Максимальний час для досягнення максимального масштабу

func _process(delta):
	fire_time = clamp(fire_time, 0, max_time)
	var current_scale = min_scale.linear_interpolate(max_scale, fire_time / max_time)
	self.scale = current_scale
