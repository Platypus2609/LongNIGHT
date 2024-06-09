extends Node2D

@export var monster_scene: PackedScene

func _ready() -> void:
	print("Game ready")
	# Видаляємо таймер, який створює монстрів кожні 10 секунд.
	# Усі спавни монстрів повинні бути керовані з Map.gd
