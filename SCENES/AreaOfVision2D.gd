extends Area2D

signal player_entered(player)
signal player_exited(player)

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))

func _on_body_entered(body):
	if body.is_in_group("Player"):
		emit_signal("player_entered", body)

func _on_body_exited(body):
	if body.is_in_group("Player"):
		emit_signal("player_exited", body)
