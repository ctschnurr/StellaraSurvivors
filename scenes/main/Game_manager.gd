extends Node
class_name Game_manager

var input_set: bool = false
var game_timer = Timer

func _ready():
	SoundManager.set_default_music_bus("Music")
	SoundManager.set_default_ambient_sound_bus("Sound")
	SoundManager.set_ambient_sound_volume(0.5)
	SoundManager.set_music_volume(0.5)
	SoundManager.play_music(App.main_music, 2.5, "Music")
	App.screen_manager.show_main_menu()


func _unhandled_input(event):
	#if input_set: return
	if event is InputEventKey:
		if event.pressed:
			App.active_input = App.input_device.KEYBOARD
			input_set = true
			
	if event is InputEventJoypadMotion:
		if event.axis_value > 0.25:
			App.active_input = App.input_device.CONTROLLER
			input_set = true


func _process(_delta):
	if !SoundManager.is_music_playing(): SoundManager.play_music(App.main_music, 2.5)
	if Input.is_action_just_pressed("F1"):
		App.screen_manager.clear_screens()
		App.screen_manager.show_controls_screen()
