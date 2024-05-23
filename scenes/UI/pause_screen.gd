extends CanvasLayer

@onready var resume_button = %ResumeButton
@onready var restart_button = %RestartButton
@onready var options_button = %OptionsButton
@onready var quit_button = %QuitButton

@onready var screen_manager: Node

func _ready():
	resume_button.grab_focus()
	resume_button.pressed.connect(resume_game)
	resume_button.mouse_entered.connect(on_resume_entered)
	resume_button.focus_entered.connect(on_focus_entered)
	restart_button.pressed.connect(play_game)
	restart_button.mouse_entered.connect(on_restart_entered)
	restart_button.focus_entered.connect(on_focus_entered)
	options_button.pressed.connect(show_options)
	options_button.mouse_entered.connect(on_options_entered)
	options_button.focus_entered.connect(on_focus_entered)
	quit_button.pressed.connect(quit_game)
	quit_button.mouse_entered.connect(on_quit_entered)
	quit_button.focus_entered.connect(on_focus_entered)
	
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


func show_options():
	screen_manager.show_options_screen("Pause_screen")
	queue_free()
	
	
func quit_game():
	print("Quit Pressed")
	screen_manager.quit_game()
	pass


func on_resume_entered():
	resume_button.grab_focus()
	
	
func on_options_entered():
	options_button.grab_focus()
	
	
func on_restart_entered():
	restart_button.grab_focus()
	
	
func on_quit_entered():
	quit_button.grab_focus()
	

func on_focus_entered():
	SoundManager.play_sound(App.asteroid_collision_sound)
