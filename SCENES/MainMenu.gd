extends Control

func _ready():
	$ButtonStartGame.connect("pressed", Callable(self, "_on_StartGame_button_pressed"))
	$ButtonQuit.connect("pressed", Callable(self, "_on_Quit_button_pressed"))

func _on_StartGame_button_pressed():
	print("Start Game Button Pressed")
	get_tree().change_scene_to_file("res://Scenes/Intro.tscn")

func _on_Quit_button_pressed():
	print("Quit Button Pressed")
	get_tree().quit()
