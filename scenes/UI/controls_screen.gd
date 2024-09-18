class_name ControlsScreen extends CanvasLayer

var play_game_module_scene: PackedScene = load("res://scenes/UI/menu_modules/play_game_module.tscn")
var arcade_module_scene: PackedScene = load("res://scenes/UI/menu_modules/arcade_module.tscn")
var options_module_scene: PackedScene = load("res://scenes/UI/options_module.tscn")
var quit_screen_scene: PackedScene = load("res://scenes/UI/quit_screen.tscn")

@onready var tree: Tree = %Tree
@onready var main_panel = %MainPanel

var items: Array

var current_screen
var current_item
var previous_item
var default_item

func _ready():
	var root = tree.create_item()
	tree.hide_root = true
	tree.hide_folding = true
	
	default_item = tree.create_item(root)
	default_item.set_text(0," ")
	default_item.visible = false
	var play_game_item = tree.create_item(root)
	play_game_item.set_text(0, "Play")
	var story_mode_item = tree.create_item(play_game_item)
	story_mode_item.set_text(0, "Survival")
	#var arcade_mode_item = tree.create_item(play_game_item)
	#arcade_mode_item.set_text(0, "Arcade")
	
	items.append(play_game_item)
	play_game_item.collapsed = true
	
	var settings_item = tree.create_item(root)
	settings_item.set_text(0, "Settings")
	var controls_item = tree.create_item(settings_item)
	controls_item.set_text(0, "Controls")
	var audio_options_item = tree.create_item(settings_item)
	audio_options_item.set_text(0, "Options")

	items.append(settings_item)
	settings_item.collapsed = true
	
	var quit_item = tree.create_item(root)
	quit_item.set_text(0, "Quit")

	tree.item_selected.connect(item_was_selected)
	previous_item = play_game_item
	
	
func previous():
	if previous_item == null: return
	previous_item.select(0)
	
	
func item_was_selected():
	SoundManager.play_ambient_sound(App.asteroid_collision_sound)
		
	if current_item != null: previous_item = current_item
	current_item = tree.get_selected()

	match current_item.get_text(0):
		"Survival":
			if current_screen != null and current_screen != StoryModule:
				current_screen.queue_free()
			
			current_screen = play_game_module_scene.instantiate()
			
		"Arcade":
			if current_screen != null and current_screen != ArcadeModule:
				current_screen.queue_free()
			
			current_screen = arcade_module_scene.instantiate()
			
			
		"Options":
			if current_screen != null and current_screen != OptionsModule:
				current_screen.queue_free()
			
			current_screen = options_module_scene.instantiate()
			
		"Quit":
			var quit_screen = quit_screen_scene.instantiate()
			quit_screen.controls_screen = self
			tree.add_child(quit_screen)
			return
			
	main_panel.add_child(current_screen)
	
	for item: TreeItem in items:
		if item != current_item && item != current_item.get_parent() && item.collapsed == false: item.collapsed = true
		
		if item == current_item && item.collapsed == true:
			current_item.set_collapsed(false)
