extends Node2D

var map_size: Vector2 = Vector2(1000, 1000)
var tree_sprites: Array = []
var rock_sprites: Array = []
var bush_sprites: Array = []
var obstacles: Array = []

@export var monster_scene: PackedScene
@export var min_distance_between_monsters: float = 150.0
@export var spawn_outside_view: bool = false  # Додаємо опцію спавну за межами камери
var monsters: Array = []

var center_area_size: Vector2 = Vector2(300, 300)
var max_iterations: int = 1000

var spawn_interval: float = 20.0  # Інтервал появи нових монстрів у секундах
var increase_monster_count_interval: float = 60.0  # Інтервал збільшення кількості монстрів у секундах
var monsters_per_spawn: int = 1  # Початкова кількість монстрів за один спавн

var spawn_timer: Timer
var increase_monster_count_timer: Timer

func _ready() -> void:
	tree_sprites = [
		load("res://ART/4 Wood/Tree1.png"),
		load("res://ART/4 Wood/Tree2.png")
	]
	
	rock_sprites = [
		load("res://ART/3 Stone/7.png"),
		load("res://ART/3 Stone/8.png"),
		load("res://ART/3 Stone/9.png"),
		load("res://ART/3 Stone/11.png"),
		load("res://ART/3 Stone/12.png"),
		load("res://ART/3 Stone/10.png")
	]
	
	bush_sprites = [
		load("res://ART/5 Bush/1.png"),
		load("res://ART/5 Bush/2.png"),
		load("res://ART/5 Bush/4.png"),
		load("res://ART/5 Bush/5.png"),
		load("res://ART/5 Bush/6.png"),
		load("res://ART/5 Bush/3.png")
	]
	
	generate_fence()
	generate_boundary()
	generate_map()
	generate_monsters()

	# Створюємо та запускаємо тільки один таймер для появи нових монстрів
	if spawn_timer:
		spawn_timer.stop()
		spawn_timer.queue_free()

	spawn_timer = Timer.new()
	spawn_timer.wait_time = spawn_interval
	spawn_timer.connect("timeout", Callable(self, "_on_SpawnTimer_timeout"))
	add_child(spawn_timer)
	spawn_timer.start()

	# Таймер для збільшення кількості монстрів
	if increase_monster_count_timer:
		increase_monster_count_timer.stop()
		increase_monster_count_timer.queue_free()

	increase_monster_count_timer = Timer.new()
	increase_monster_count_timer.wait_time = increase_monster_count_interval
	increase_monster_count_timer.connect("timeout", Callable(self, "_on_IncreaseMonsterCountTimer_timeout"))
	add_child(increase_monster_count_timer)
	increase_monster_count_timer.start()

	print("Map ready")

func generate_fence() -> void:
	var sprite_arrays = [tree_sprites, rock_sprites, bush_sprites]
	var tile_size = 64

	for x in range(int(map_size.x / tile_size)):
		generate_obstacle_at_position(sprite_arrays, Vector2(x * tile_size, 0))
		generate_obstacle_at_position(sprite_arrays, Vector2(x * tile_size, map_size.y - tile_size))

	for y in range(int(map_size.y / tile_size)):
		generate_obstacle_at_position(sprite_arrays, Vector2(0, y * tile_size))
		generate_obstacle_at_position(sprite_arrays, Vector2(map_size.x - tile_size, y * tile_size))

func generate_boundary() -> void:
	var boundary = StaticBody2D.new()
	add_child(boundary)

	var top_collision = CollisionShape2D.new()
	var top_shape = RectangleShape2D.new()
	top_shape.extents = Vector2(map_size.x / 2, 10)
	top_collision.shape = top_shape
	top_collision.position = Vector2(map_size.x / 2, -10)
	boundary.add_child(top_collision)

	var bottom_collision = CollisionShape2D.new()
	var bottom_shape = RectangleShape2D.new()
	bottom_shape.extents = Vector2(map_size.x / 2, 10)
	bottom_collision.shape = bottom_shape
	bottom_collision.position = Vector2(map_size.x / 2, map_size.y + 10)
	boundary.add_child(bottom_collision)

	var left_collision = CollisionShape2D.new()
	var left_shape = RectangleShape2D.new()
	left_shape.extents = Vector2(10, map_size.y / 2)
	left_collision.shape = left_shape
	left_collision.position = Vector2(-10, map_size.y / 2)
	boundary.add_child(left_collision)

	var right_collision = CollisionShape2D.new()
	var right_shape = RectangleShape2D.new()
	right_shape.extents = Vector2(10, map_size.y / 2)
	right_collision.shape = right_shape
	right_collision.position = Vector2(map_size.x + 10, map_size.y / 2)
	boundary.add_child(right_collision)

	print("Boundary generated")

func generate_obstacle_at_position(sprite_arrays: Array, pos: Vector2) -> void:
	var sprite_array = sprite_arrays[randi() % sprite_arrays.size()]
	var sprite = sprite_array[randi() % sprite_array.size()]

	var instance = StaticBody2D.new()
	var sprite_node = Sprite2D.new()
	sprite_node.texture = sprite
	instance.add_child(sprite_node)
	instance.position = pos
	add_child(instance)
	obstacles.append(instance)

	var collision_shape = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.extents = sprite_node.texture.get_size() / 2
	collision_shape.shape = shape
	instance.add_child(collision_shape)
	collision_shape.position = Vector2()

func generate_map() -> void:
	var num_trees = 30
	var num_rocks = 20
	var num_bushes = 50
	
	for i in range(num_trees):
		generate_obstacle(tree_sprites)

	for i in range(num_rocks):
		generate_obstacle(rock_sprites)

	for i in range(num_bushes):
		generate_obstacle(bush_sprites)

	print("Map generated")

func generate_obstacle(sprites_array: Array) -> void:
	var random_position = Vector2()
	var valid_position = false
	var sprite = null
	var iterations = 0

	while not valid_position and iterations < max_iterations:
		sprite = sprites_array[randi() % sprites_array.size()]
		random_position = Vector2(randi() % int(map_size.x), randi() % int(map_size.y))

		if random_position.x > (map_size.x / 2 - center_area_size.x / 2) and random_position.x < (map_size.x / 2 + center_area_size.x / 2) and random_position.y > (map_size.y / 2 - center_area_size.x / 2) and random_position.y < (map_size.y / 2 + center_area_size.x / 2):
			valid_position = false
		else:
			valid_position = true
			var instance_rect = Rect2(random_position, Vector2(64, 64))
			for obstacle in obstacles:
				if obstacle and obstacle.is_inside_tree():
					var obstacle_rect = Rect2(obstacle.position, Vector2(64, 64))
					if instance_rect.intersects(obstacle_rect):
						valid_position = false
						break

		iterations += 1

	if valid_position:
		var instance = StaticBody2D.new()
		var sprite_node = Sprite2D.new()
		sprite_node.texture = sprite
		instance.add_child(sprite_node)
		instance.position = random_position
		add_child(instance)
		obstacles.append(instance)

		var collision_shape = CollisionShape2D.new()
		var shape = RectangleShape2D.new()
		shape.extents = sprite_node.texture.get_size() / 2
		collision_shape.shape = shape
		instance.add_child(collision_shape)
		collision_shape.position = Vector2()

func generate_monsters() -> void:
	for i in range(3):
		spawn_monster()

	print("Monsters generated")

func spawn_monster() -> void:
	if monster_scene == null:
		print("monster_scene is not set. Please assign a PackedScene to the monster_scene variable.")
		return

	var random_position = get_random_position()
	var new_monster = monster_scene.instantiate()
	new_monster.position = random_position
	add_child(new_monster)
	monsters.append(weakref(new_monster))  # Використовуємо слабкі посилання
	new_monster.connect("died", Callable(self, "_on_monster_died").bindv([weakref(new_monster)]))
	new_monster.add_to_group("Monsters")
	print("Spawned monster at: ", random_position, " Current monster count: ", monsters.size())

func get_random_position() -> Vector2:
	if spawn_outside_view:
		# Спавн за межами видимої камери
		var camera = get_viewport().get_camera_2d()
		if camera:
			var view_rect = camera.get_viewport_rect()
			var viewport = get_viewport()
			var screen_size = viewport.get_visible_rect().size
			var camera_pos = camera.global_position
			var random_position = Vector2()
			var side = randi() % 4  # Випадкова сторона (0 - ліво, 1 - право, 2 - верх, 3 - низ)

			if side == 0:
				random_position.x = camera_pos.x - screen_size.x / 2 - 50
				random_position.y = camera_pos.y + randf() * screen_size.y - screen_size.y / 2
			elif side == 1:
				random_position.x = camera_pos.x + screen_size.x / 2 + 50
				random_position.y = camera_pos.y + randf() * screen_size.y - screen_size.y / 2
			elif side == 2:
				random_position.x = camera_pos.x + randf() * screen_size.x - screen_size.x / 2
				random_position.y = camera_pos.y - screen_size.y / 2 - 50
			elif side == 3:
				random_position.x = camera_pos.x + randf() * screen_size.x - screen_size.x / 2
				random_position.y = camera_pos.y + screen_size.y / 2 + 50

			# Перевірка, що позиція знаходиться всередині мапи
			random_position.x = clamp(random_position.x, 0, map_size.x)
			random_position.y = clamp(random_position.y, 0, map_size.y)

			return random_position
		else:
			print("No camera found. Spawning inside the map.")
	else:
		while true:
			var random_position = Vector2(randf() * map_size.x, randf() * map_size.y)
			var valid_position = true

			for monster_ref in monsters:
				var monster = monster_ref.get_ref()
				if monster and monster.is_inside_tree():
					if random_position.distance_to(monster.position) < min_distance_between_monsters:
						valid_position = false
						break

			if valid_position:
				return random_position
	return Vector2()

func _on_monster_died(monster_ref) -> void:
	var monster = monster_ref.get_ref()
	monsters.erase(monster_ref)
	print("Monster died. Current monster count: ", monsters.size())

func _on_SpawnTimer_timeout() -> void:
	for i in range(monsters_per_spawn):
		spawn_monster()
	print("Spawn timer timeout. Current monster count: ", monsters.size(), " Monsters spawned: ", monsters_per_spawn)

func _on_IncreaseMonsterCountTimer_timeout() -> void:
	monsters_per_spawn += 1
	print("Increased monsters per spawn to: ", monsters_per_spawn)
