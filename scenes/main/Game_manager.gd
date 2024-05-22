extends Node
class_name Game_manager

var input_set: bool = false

func _ready():
	App.screen_manager.show_main_menu()



		
		
func _unhandled_input(event):
	#if input_set: return
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ENTER:
			App.active_input = App.input_device.KEYBOARD
			print("Input set: ", App.active_input)
			input_set = true
			
	if event is InputEventJoypadButton:
		if event.pressed:
			App.active_input = App.input_device.CONTROLLER
			print("Input set: ", App.active_input)
			input_set = true

