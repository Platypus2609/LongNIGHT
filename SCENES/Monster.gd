extends CharacterBody2D

@export var speed = 50
@export var vision_radius = 100
@export var patrol_area_radius = 150
@export var sound_path = "res://sounds/Zombie.mp3"
@export var sound_interval = 4  # Інтервал в секундах для відтворення звуку
@export var attack_interval = 1.5  # Інтервал в секундах між атаками
@export var avoid_distance = 50  # Відстань уникнення між монстрами
@export var attack_damage_min = 10
@export var attack_damage_max = 20
@export var minimum_distance_to_player = 20  # Мінімальна відстань до гравця

signal died  # Додаємо сигнал

var player_detected = false
var player = null
var player_position = Vector2()
var initial_position = Vector2()
var patrol_target = Vector2()
var is_patrolling = true
var time_since_last_sound = 0
var time_since_last_attack = 0

func _ready():
	initial_position = global_position
	generate_new_patrol_target()

	# Налаштування зони видимості
	var vision = $AreaOfVision2D
	vision.connect("body_entered", Callable(self, "_on_body_entered"))
	vision.connect("body_exited", Callable(self, "_on_body_exited"))
	vision.get_node("CollisionShape2D").shape.radius = vision_radius

	# Переконаємося, що AreaOfVision2D правильно розташований відносно монстра
	$AreaOfVision2D.position = Vector2.ZERO

	# Налаштування аудіо-плеєра
	var audio_player = $AudioStreamPlayer
	audio_player.stream = load(sound_path)
	
	print("Monster is ready")

func _physics_process(delta):
	if player_detected and player != null:
		time_since_last_sound += delta
		time_since_last_attack += delta
		if time_since_last_sound >= sound_interval:
			play_sound()
			time_since_last_sound = 0  # Скидання таймера

		update_player_position()
		chase_player()

		if time_since_last_attack >= attack_interval and global_position.distance_to(player.global_position) < 50:  # Перевірка відстані для атаки
			attack_player()
			time_since_last_attack = 0  # Скидання таймера для атаки
	elif is_patrolling:
		patrol()
	else:
		velocity = Vector2.ZERO

	avoid_other_monsters()
	move_and_slide()

func update_player_position():
	player_position = player.global_position

func chase_player():
	if player:
		var distance_to_player = global_position.distance_to(player_position)
		if distance_to_player > minimum_distance_to_player:
			var direction = (player_position - global_position).normalized()
			velocity = direction * speed
			print("Chasing player. Direction: ", direction, ", Velocity: ", velocity)
		else:
			# Відступити на деяку відстань
			var direction = (global_position - player_position).normalized()
			velocity = direction * speed
			print("Too close to player. Stepping back. Direction: ", direction, ", Velocity: ", velocity)

func patrol():
	if global_position.distance_to(patrol_target) < 10:
		generate_new_patrol_target()
	var to_target = (patrol_target - global_position).normalized()
	velocity = to_target * speed
	print("Patrolling. Target: ", patrol_target, ", Direction: ", to_target, ", Velocity: ", velocity)

func generate_new_patrol_target():
	var angle = randf() * PI * 2
	patrol_target = initial_position + Vector2(cos(angle), sin(angle)) * patrol_area_radius
	print("New patrol target generated: ", patrol_target)

func _on_body_entered(body):
	if body.is_in_group("Player"):
		player_detected = true
		player = body
		player_position = player.global_position
		is_patrolling = false  # Монстр припиняє патрулювати назавжди
		play_sound()  # Відтворюємо звук одразу після виявлення гравця
		time_since_last_sound = 0  # Скидаємо таймер після першого звуку
		print("Player entered vision area at position: ", player_position)

func _on_body_exited(body):
	if body.is_in_group("Player"):
		# Навіть якщо гравець вийде з поля зору, монстр продовжує переслідування
		print("Player exited vision area, but monster continues chasing")

func play_sound():
	if not $AudioStreamPlayer.playing:
		$AudioStreamPlayer.play()
		print("Playing sound")

func attack_player():
	if player:
		var damage = randi() % (attack_damage_max - attack_damage_min + 1) + attack_damage_min  # Генерація випадкової шкоди від attack_damage_min до attack_damage_max
		player.take_damage(damage)
		print("Attacking player with damage: ", damage)

func avoid_other_monsters():
	var all_monsters = get_tree().get_nodes_in_group("Monsters")
	for monster in all_monsters:
		if monster != self and global_position.distance_to(monster.global_position) < avoid_distance:
			var avoid_direction = (global_position - monster.global_position).normalized()
			velocity += avoid_direction * speed * 0.5  # Налаштування сили відштовхування
			print("Avoiding other monster. Direction: ", avoid_direction, ", Velocity: ", velocity)

func die():
	emit_signal("died")
	queue_free()
