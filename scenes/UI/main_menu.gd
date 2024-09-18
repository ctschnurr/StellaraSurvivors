extends CanvasLayer

@onready var play_button = %PlayButton
@onready var options_button = %OptionsButton
@onready var quit_button = %QuitButton

@onready var screen_manager: Screen_Manager

func _ready():
	play_button.grab_focus()
	play_button.pressed.connect(play_game)
	play_button.mouse_entered.connect(on_play_entered)
	play_button.focus_entered.connect(on_focus_entered)
	options_button.pressed.connect(show_options)
	options_button.mouse_entered.connect(on_options_entered)
	options_button.focus_entered.connect(on_focus_entered)
	quit_button.pressed.connect(quit_game)
	quit_button.mouse_entered.connect(on_quit_entered)
	quit_button.focus_entered.connect(on_focus_entered)
	
	
func play_game():
	SoundManager.play_sound(App.upgrade_selected_sound)
	screen_manager.play_game()
	queue_free()
	pass
	
	
func show_options():
	screen_manager.show_options_screen("Main_menu")
	queue_free()
	
	
func quit_game():
	print("Quit Pressed")
	screen_manager.quit_game()
	pass
	
	
func on_play_entered():
	play_button.grab_focus()
	
	
func on_options_entered():
	options_button.grab_focus()
	
	
func on_quit_entered():
	quit_button.grab_focus()
	
	
func on_focus_entered():
	SoundManager.play_sound(App.asteroid_collision_sound)
	
	

