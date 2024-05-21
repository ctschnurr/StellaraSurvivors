extends CanvasLayer

@onready var replay_button = %ReplayButton
@onready var quit_button = %QuitButton


func _ready():
	replay_button.pressed.connect(play_game)
	quit_button.pressed.connect(quit_game)
	
	
func play_game():
	App.screen_manager.play_game()
	queue_free()
	pass
	
	
func quit_game():
	App.screen_manager.quit_game()
	pass
