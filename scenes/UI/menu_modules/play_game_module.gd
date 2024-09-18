class_name PlayGameModule extends MarginContainer

@onready var game_mode_button: OptionButton = %GameModeButton
@onready var custom_mode_window: MarginContainer = %CustomModeWindow

func _ready():
	game_mode_button.item_selected.connect(game_mode_selected)
	pass


func game_mode_selected(selection):
	if selection != 4 and custom_mode_window.visible: custom_mode_window.visible = false
	
	match selection:
		0:
			# 5 Minute Survival
			pass
		1:
			# 15 Minute Survival
			pass
		2:
			# 30 Minute Survival
			pass
		3:
			# Endless Survival
			pass
		4:
			# Custom Mode
			if !custom_mode_window.visible: custom_mode_window.visible = true
			pass
		_:
			#Error Catch
			pass
			
	pass
