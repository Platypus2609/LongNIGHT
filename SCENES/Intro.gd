extends Control

func _ready():
	print("Intro Scene Loaded")
	var note_text = "Привіт! Краще б тобі цього не читати!\n"
	note_text += "Я намагався протриматися якомога довше, але монстри всюди. Щоб залишитися в живих, я зрозумів кілька речей:\n"
	note_text += "1. Підтримуй вогонь, збираючи гілки. Вогонь відлякує монстрів.\n"
	note_text += "2. Арбалетні болти допоможуть тобі захищатися. Збирай їх у лісі. Попереднім власникам вони вже не знадобляться.\n"
	note_text += "3. Монстри бояться світла від вогнища. Тримай вогонь якомога довше.\n"
	note_text += "Я не знаю, скільки ще протримаюся... Бережись і не здавайся.\n"
	note_text += "Щасти! Це буде довга ніч!"
	$Label.text = note_text

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		print("Переходжу до сцени Game")
		get_tree().change_scene_to_file("res://Scenes/Game.tscn")
