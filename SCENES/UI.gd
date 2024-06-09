extends CanvasLayer

var game_time = 0.0
var player = null

func _ready():
	player = get_parent().get_node("Player")

func _process(delta):
	game_time += delta
	$Label.text = "Health: %d\nTime: %.2f" % [player.health, game_time]
