extends CanvasLayer

@onready var replay_button = %ReplayButton
@onready var quit_button = %QuitButton

func _ready():
	SoundManager.play_sound(App.level_up_sound)
	
	replay_button.grab_focus()
	replay_button.pressed.connect(restart_game)
	replay_button.mouse_entered.connect(on_play_entered)
	replay_button.focus_entered.connect(on_focus_entered)
	quit_button.pressed.connect(quit_game)
	quit_button.mouse_entered.connect(on_quit_entered)
	quit_button.focus_entered.connect(on_focus_entered)
	
	
func restart_game():
	SoundManager.play_sound(App.upgrade_selected_sound)
	App.screen_manager.restart_game()
	queue_free()
	pass


func quit_game():
	App.screen_manager.quit_game()

	
func on_play_entered():
	replay_button.grab_focus()
	
	
func on_quit_entered():
	quit_button.grab_focus()

	
func on_focus_entered():
	SoundManager.play_sound(App.asteroid_collision_sound)
