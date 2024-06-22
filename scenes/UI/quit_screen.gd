class_name QuitScreen extends CanvasLayer

@onready var back_button: Button = %BackButton
@onready var quit_button: Button = %QuitButton

@export var controls_screen: ControlsScreen

func _ready():
	back_button.pressed.connect(back_button_pressed)
	quit_button.pressed.connect(quit_pressed)


func back_button_pressed():
	controls_screen.previous()
	queue_free()
	
	
func quit_pressed():
	App.quit_game()
