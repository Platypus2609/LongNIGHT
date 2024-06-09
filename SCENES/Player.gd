extends CharacterBody2D

@export var speed = 200
var health = 100
var max_health = 100

func _ready():
	print("Player ready")
	$AnimationPlayer.play("idleS")
	set_process(true)
	add_to_group("Player")

func _process(_delta):
	var movement_velocity = Vector2()
	if Input.is_action_pressed("ui_right"):
		movement_velocity.x += 1
	if Input.is_action_pressed("ui_left"):
		movement_velocity.x -= 1
	if Input.is_action_pressed("ui_down"):
		movement_velocity.y += 1
	if Input.is_action_pressed("ui_up"):
		movement_velocity.y -= 1

	movement_velocity = movement_velocity.normalized() * speed
	velocity = movement_velocity
	move_and_slide()

	if velocity.length() > 0:
		if not $AnimationPlayer.is_playing() or $AnimationPlayer.current_animation != "idleS":
			$AnimationPlayer.play("idleS")
	else:
		if $AnimationPlayer.is_playing():
			$AnimationPlayer.stop()

func take_damage(damage):
	health -= damage
	print("Player took damage! Health: ", health)
	if health <= 0:
		die()

func die():
	queue_free()
	print("Player died")
