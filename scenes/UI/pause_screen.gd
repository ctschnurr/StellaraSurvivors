extends CanvasLayer

@onready var resume_button = %ResumeButton
@onready var restart_button = %RestartButton
@onready var quit_button = %QuitButton

@onready var screen_manager: Node

func _ready():
	resume_button.pressed.connect(resume_game)
	restart_button.pressed.connect(play_game)
	quit_button.pressed.connect(quit_game)
	resume_button.grab_focus()
	
func _process(_delta):
	if Input.is_action_just_pressed("escape"):
		resume_game()
	
	
func resume_game():
	queue_free()
	get_tree().paused = false
	
	
func play_game():
	screen_manager.play_game()
	queue_free()
	pass
	
	
func quit_game():
	print("Quit Pressed")
	screen_manager.quit_game()
	pass
