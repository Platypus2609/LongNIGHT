extends Control

func _ready() -> void:
	$ButtonStartGame.connect("pressed", Callable(self, "_on_StartGame_button_pressed"))
	$ButtonQuit.connect("pressed", Callable(self, "_on_Quit_button_pressed"))

func _on_StartGame_button_pressed() -> void:
	print("Start Game Button Pressed")
	get_tree().change_scene_to_file("res://Scenes/Intro.tscn")

func _on_Quit_button_pressed() -> void:
	print("Quit Button Pressed")
	get_tree().quit()
