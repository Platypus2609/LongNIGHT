extends Light2D

var fire_time = 100.0
var max_scale = Vector2(2, 2)  # Максимальний масштаб
var min_scale = Vector2(0.2, 0.2)  # Мінімальний масштаб
var max_time = 100  # Максимальний час для досягнення максимального масштабу

func _process(_delta):
	fire_time = clamp(fire_time, 0, max_time)
	var t = fire_time / max_time
	var current_scale = min_scale.lerp(max_scale, t)
	self.scale = current_scale
