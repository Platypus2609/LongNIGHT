extends Area2D

@export var fire_time = 100.0
@export var max_scale = Vector2(2, 2)  # Максимальний масштаб
@export var min_scale = Vector2(0.2, 0.2)  # Мінімальний масштаб
@export var max_time = 100  # Максимальний час для досягнення максимального масштабу
@export var heal_radius = 50  # Радіус зони відновлення здоров'я
@export var heal_amount = 1  # Кількість відновлюваного здоров'я
@export var heal_interval = 1.0  # Інтервал відновлення здоров'я в секундах

var light_node = null
var heal_timer = null
var player_in_range = false

func _ready():
	light_node = $PointLight2D
	if light_node == null:
		print("PointLight2D not found!")
	else:
		print("PointLight2D found!")

	# Переконайтеся, що AnimationPlayer відтворює анімацію "fire"
	var animation_player = $AnimationPlayer
	if animation_player == null:
		print("AnimationPlayer not found!")
	else:
		if not animation_player.is_playing() or animation_player.current_animation != "fire":
			print("Playing fire animation")
			animation_player.play("fire")

	# Налаштування колізійної форми для зони відновлення здоров'я
	var shape = $HealingArea.shape
	if shape is CircleShape2D:
		shape.radius = heal_radius
	print("Campfire is ready with heal radius: ", heal_radius)

	# Налаштування таймера для відновлення здоров'я
	heal_timer = Timer.new()
	heal_timer.wait_time = heal_interval
	heal_timer.connect("timeout", Callable(self, "_on_heal_timer_timeout"))
	add_child(heal_timer)

	connect("area_entered", Callable(self, "_on_area_entered"))
	connect("area_exited", Callable(self, "_on_area_exited"))

func _process(_delta):
	fire_time = clamp(fire_time, 0, max_time)
	var t = fire_time / max_time
	var current_scale = min_scale.lerp(max_scale, t)
	if light_node != null:
		light_node.scale = current_scale

func _on_area_entered(area):
	print("Area entered: ", area.name)
	if area.is_in_group("Player"):
		player_in_range = true
		heal_timer.start()
		print("Player entered fire range")
	elif area.is_in_group("Monster"):
		print("Monster entered fire range and will be removed: ", area.name)
		area.queue_free()
		print("Monster removed: ", area.name)

func _on_area_exited(area):
	print("Area exited: ", area.name)
	if area.is_in_group("Player"):
		player_in_range = false
		heal_timer.stop()
		print("Player exited fire range")

func _on_heal_timer_timeout():
	if player_in_range:
		var player = get_tree().get_nodes_in_group("Player")[0]
		if player:
			player.health = min(player.max_health, player.health + heal_amount)
			print("Player healed: ", player.health)

func add_fire_time(amount):
	fire_time = clamp(fire_time + amount, 0, max_time)
	print("Added fire time: ", amount, " New fire time: ", fire_time)

func reduce_fire_time(amount):
	fire_time = clamp(fire_time - amount, 0, max_time)
	print("Reduced fire time: ", amount, " New fire time: ", fire_time)
