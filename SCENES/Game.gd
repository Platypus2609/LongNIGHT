extends Node2D

@export var monster_scene: PackedScene

var max_monsters = 3
var monsters = []

func _ready():
	var map_node = get_node("Map")
	if map_node == null:
		print("Map node not found. Please ensure that the Map node exists and is correctly named.")
		return

	print("Game ready, monsters count: ", max_monsters)
	
	# Таймер для перевірки кількості монстрів
	var spawn_timer = Timer.new()
	spawn_timer.wait_time = 10.0  # Генерація монстрів кожні 10 секунд
	spawn_timer.connect("timeout", Callable(self, "_on_SpawnTimer_timeout"))
	add_child(spawn_timer)
	spawn_timer.start()

	# Спавнимо монстрів при старті
	check_and_spawn_monsters()

func _on_SpawnTimer_timeout():
	print("Spawn timer timeout")
	check_and_spawn_monsters()

func check_and_spawn_monsters():
	print("Checking and spawning monsters")
	while monsters.size() < max_monsters:
		spawn_monster()

func spawn_monster():
	if monster_scene == null:
		print("monster_scene is not set. Please assign a PackedScene to the monster_scene variable.")
		return

	var new_monster = monster_scene.instantiate()
	new_monster.connect("died", Callable(self, "_on_monster_died").bind(new_monster))
	add_child(new_monster)
	
	var map_node = get_node("Map")
	if map_node != null:
		new_monster.position = map_node.call("get_random_position")
	else:
		print("Map node not found. Cannot set monster position.")
	
	monsters.append(new_monster)
	print("Spawned monster at: ", new_monster.position)

func _on_monster_died(monster):
	if monster in monsters:
		monsters.erase(monster)
		print("Monster removed: ", monster.name)
	check_and_spawn_monsters()
