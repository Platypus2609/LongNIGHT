extends CanvasLayer

var game_time: float = 0.0
var player: Node2D = null

func _ready() -> void:
	player = get_parent().get_node("Player")

func _process(delta: float) -> void:
	game_time += delta
	$Label.text = "Health: %d\nTime: %.2f" % [player.health, game_time]
