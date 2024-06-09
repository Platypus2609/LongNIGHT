extends Area2D

@export var fire_time: float = 100.0
@export var max_scale: Vector2 = Vector2(2, 2)
@export var min_scale: Vector2 = Vector2(0.2, 0.2)
@export var max_time: float = 100.0
@export var heal_radius: float = 50.0
@export var heal_amount: int = 1
@export var heal_interval: float = 1.0

var light_node: PointLight2D
var heal_timer: Timer
var player_in_range: bool = false

func _ready():
	light_node = $PointLight2D
	if light_node == null:
		print("PointLight2D not found!")
	else:
		print("PointLight2D found!")
	
	var animation_player = $AnimationPlayer
	if animation_player == null:
		print("AnimationPlayer not found!")
	else:
		if not animation_player.is_playing() or animation_player.current_animation != "fire":
			print("Playing fire animation")
			animation_player.play("fire")

	var shape = $HealingArea.shape
	if shape is CircleShape2D:
		shape.radius = heal_radius
	print("Campfire is ready with heal radius: ", heal_radius)

	heal_timer = Timer.new()
	heal_timer.wait_time = heal_interval
	heal_timer.connect("timeout", Callable(self, "_on_heal_timer_timeout"))
	add_child(heal_timer)

	connect("area_entered", Callable(self, "_on_area_entered"))
	connect("area_exited", Callable(self, "_on_area_exited"))

func _process(_delta: float) -> void:
	fire_time = clamp(fire_time, 0, max_time)
	var t = fire_time / max_time
	var current_scale = min_scale.lerp(max_scale, t)
	if light_node != null:
		light_node.scale = current_scale

func _on_area_entered(area: Node) -> void:
	print("Area entered: ", area.name)
	if area.is_in_group("Player"):
		player_in_range = true
		heal_timer.start()
		print("Player entered fire range")
	elif area.is_in_group("Monster"):
		print("Monster entered fire range and will be removed: ", area.name)
		area.queue_free()
		print("Monster removed: ", area.name)

func _on_area_exited(area: Node) -> void:
	print("Area exited: ", area.name)
	if area.is_in_group("Player"):
		player_in_range = false
		heal_timer.stop()
		print("Player exited fire range")

func _on_heal_timer_timeout() -> void:
	if player_in_range:
		var players = get_tree().get_nodes_in_group("Player")
		if players.size() > 0:
			var player = players[0]
			player.health = min(player.max_health, player.health + heal_amount)
			print("Player healed: ", player.health)

func add_fire_time(amount: float) -> void:
	fire_time = clamp(fire_time + amount, 0, max_time)
	print("Added fire time: ", amount, " New fire time: ", fire_time)

func reduce_fire_time(amount: float) -> void:
	fire_time = clamp(fire_time - amount, 0, max_time)
	print("Reduced fire time: ", amount, " New fire time: ", fire_time)
