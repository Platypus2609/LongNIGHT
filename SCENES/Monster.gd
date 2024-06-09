extends CharacterBody2D

@export var speed: float = 50.0
@export var vision_radius: float = 100.0
@export var patrol_radius: float = 200.0  # Радіус патрулювання
@export var sound_path: String = "res://sounds/Zombie.mp3"
@export var sound_interval: float = 4.0
@export var attack_interval: float = 1.5
@export var avoid_distance: float = 50.0
@export var attack_damage_min: int = 10
@export var attack_damage_max: int = 20
@export var minimum_distance_to_player: float = 20.0

signal died

var player_detected: bool = false
var player: Node2D = null
var player_position: Vector2 = Vector2()
var initial_position: Vector2 = Vector2()
var patrol_angle: float = 0.0
var patrol_direction: int = 1  # 1 for clockwise, -1 for counterclockwise
var time_since_last_sound: float = 0.0
var time_since_last_attack: float = 0.0

func _ready() -> void:
	initial_position = global_position
	patrol_angle = randf() * PI * 2

	var vision = $AreaOfVision2D
	vision.connect("body_entered", Callable(self, "_on_body_entered"))
	vision.connect("body_exited", Callable(self, "_on_body_exited"))
	vision.get_node("CollisionShape2D").shape.radius = vision_radius

	$AreaOfVision2D.position = Vector2.ZERO

	var audio_player = $AudioStreamPlayer
	audio_player.stream = load(sound_path)
	
	print("Monster is ready")

func _physics_process(delta: float) -> void:
	if player_detected and player and player.is_inside_tree():
		time_since_last_sound += delta
		time_since_last_attack += delta
		if time_since_last_sound >= sound_interval:
			play_sound()
			time_since_last_sound = 0.0

		update_player_position()
		chase_player()

		if time_since_last_attack >= attack_interval and global_position.distance_to(player.global_position) < 50.0:
			attack_player()
			time_since_last_attack = 0.0
	else:
		patrol(delta)

	avoid_other_monsters()
	move_and_slide()

func update_player_position() -> void:
	if player and player.is_inside_tree():
		player_position = player.global_position

func chase_player() -> void:
	if player:
		var distance_to_player = global_position.distance_to(player_position)
		if distance_to_player > minimum_distance_to_player:
			var direction = (player_position - global_position).normalized()
			velocity = direction * speed
		else:
			var direction = (global_position - player_position).normalized()
			velocity = direction * speed

func patrol(delta: float) -> void:
	patrol_angle += patrol_direction * speed * delta / patrol_radius
	var patrol_target = initial_position + Vector2(cos(patrol_angle), sin(patrol_angle)) * patrol_radius
	var to_target = (patrol_target - global_position).normalized()
	velocity = to_target * speed

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_detected = true
		player = body
		player_position = player.global_position
		play_sound()
		time_since_last_sound = 0.0

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		# Монстр продовжує переслідування гравця навіть після виходу з зони видимості
		pass

func play_sound() -> void:
	if not $AudioStreamPlayer.playing:
		$AudioStreamPlayer.play()

func attack_player() -> void:
	if player and player.is_inside_tree():
		var damage = randi() % (attack_damage_max - attack_damage_min + 1) + attack_damage_min
		player.take_damage(damage)

func avoid_other_monsters() -> void:
	var all_monsters = get_tree().get_nodes_in_group("Monsters")
	for monster in all_monsters:
		if monster != self and monster and monster.is_inside_tree():
			if global_position.distance_to(monster.global_position) < avoid_distance:
				var avoid_direction = (global_position - monster.global_position).normalized()
				velocity += avoid_direction * speed * 0.5

func die() -> void:
	emit_signal("died")
	queue_free()
