extends Node2D

var map_size = Vector2(1000, 1000)  # Розмір карти
var tree_sprites = []  # Масив спрайтів дерев
var rock_sprites = []  # Масив спрайтів каміння
var bush_sprites = []  # Масив спрайтів кущів
var obstacles = []  # Масив для зберігання всіх перешкод

@export var monster_scene: PackedScene
@export var monster_count = 3
@export var min_distance_between_monsters = 150
var monsters = []

# Центральна область, де об'єкти не повинні генеруватися
var center_area_size = Vector2(300, 300)  # Розмір центральної області
var max_iterations = 1000  # Максимальна кількість ітерацій для уникнення нескінченних циклів

func _ready():
	# Завантаження спрайтів дерев, каміння та кущів
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
	
	# Генерація паркану
	generate_fence()

	# Генерація обмеження по периметру
	generate_boundary()

	# Генерація карти
	generate_map()

	print("Map ready")

func generate_fence():
	var sprite_arrays = [tree_sprites, rock_sprites, bush_sprites]
	var tile_size = 64  # Припустимо, що розмір кожного тайлу 64x64 пікселі

	# Верхній та нижній край
	for x in range(int(map_size.x / tile_size)):
		generate_obstacle_at_position(sprite_arrays, Vector2(x * tile_size, 0))
		generate_obstacle_at_position(sprite_arrays, Vector2(x * tile_size, map_size.y - tile_size))

	# Лівий та правий край
	for y in range(int(map_size.y / tile_size)):
		generate_obstacle_at_position(sprite_arrays, Vector2(0, y * tile_size))
		generate_obstacle_at_position(sprite_arrays, Vector2(map_size.x - tile_size, y * tile_size))

	print("Fence generated")

func generate_boundary():
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

func generate_obstacle_at_position(sprite_arrays, pos):
	var sprite_array = sprite_arrays[randi() % sprite_arrays.size()]
	var sprite = sprite_array[randi() % sprite_array.size()]

	var instance = StaticBody2D.new()  # Використовуємо StaticBody2D для перешкод
	var sprite_node = Sprite2D.new()
	sprite_node.texture = sprite
	instance.add_child(sprite_node)
	instance.position = pos
	add_child(instance)
	obstacles.append(instance)

	# Додаємо CollisionShape2D для непрохідності
	var collision_shape = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.extents = sprite.get_size() / 2
	collision_shape.shape = shape
	instance.add_child(collision_shape)
	collision_shape.position = Vector2()

func generate_map():
	var num_trees = 30  # Кількість дерев
	var num_rocks = 20  # Кількість каміння
	var num_bushes = 50  # Кількість кущів
	
	# Генерація дерев
	for i in range(num_trees):
		generate_obstacle(tree_sprites)

	# Генерація каміння
	for i in range(num_rocks):
		generate_obstacle(rock_sprites)

	# Генерація кущів
	for i in range(num_bushes):
		generate_obstacle(bush_sprites)

	print("Map generated")

func generate_obstacle(sprites_array):
	var random_position = Vector2()
	var valid_position = false
	var sprite = null
	var iterations = 0

	while not valid_position and iterations < max_iterations:
		sprite = sprites_array[randi() % sprites_array.size()]
		random_position = Vector2(randi() % int(map_size.x), randi() % int(map_size.y))

		# Перевірка, чи позиція не знаходиться в центрі карти
		if random_position.x > (map_size.x / 2 - center_area_size.x / 2) and random_position.x < (map_size.x / 2 + center_area_size.x / 2) and random_position.y > (map_size.y / 2 - center_area_size.x / 2) and random_position.y < (map_size.y / 2 + center_area_size.x / 2):
			valid_position = false
		else:
			valid_position = true
			var instance_rect = Rect2(random_position, Vector2(64, 64))  # Припустимо, що розмір кожного об'єкта 64x64 пікселі
			for obstacle in obstacles:
				var obstacle_rect = Rect2(obstacle.position, Vector2(64, 64))
				if instance_rect.intersects(obstacle_rect):
					valid_position = false
					break

		iterations += 1

	if valid_position:
		var instance = StaticBody2D.new()  # Використовуємо StaticBody2D для перешкод
		var sprite_node = Sprite2D.new()
		sprite_node.texture = sprite
		instance.add_child(sprite_node)
		instance.position = random_position
		add_child(instance)
		obstacles.append(instance)

		# Додаємо CollisionShape2D для непрохідності
		var collision_shape = CollisionShape2D.new()
		var shape = RectangleShape2D.new()
		shape.extents = sprite.get_size() / 2
		collision_shape.shape = shape
		instance.add_child(collision_shape)
		collision_shape.position = Vector2()

func get_random_position():
	while true:
		var random_position = Vector2(randf() * map_size.x, randf() * map_size.y)
		var valid_position = true

		for monster in monsters:
			if random_position.distance_to(monster.position) < min_distance_between_monsters:
				valid_position = false
				break

		if valid_position:
			print("Generated random position for monster: ", random_position)
			return random_position
