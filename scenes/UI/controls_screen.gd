extends CanvasLayer

	
@onready var tree: Tree = %Tree
var items: Array

func _ready():
	var root = tree.create_item()
	tree.hide_root = true
	tree.hide_folding = true
	
	var play_game_item = tree.create_item(root)
	play_game_item.set_text(0, "Play Game")
	var story_mode_item = tree.create_item(play_game_item)
	story_mode_item.set_text(0, "Story Mode")
	var arcade_mode_item = tree.create_item(play_game_item)
	arcade_mode_item.set_text(0, "Arcade Mode")
	
	items.append(play_game_item)
	play_game_item.collapsed = true
	
	
	var settings_item = tree.create_item(root)
	settings_item.set_text(0, "Settings")
	var audio_options_item = tree.create_item(settings_item)
	audio_options_item.set_text(0, "Audio Options")

	items.append(settings_item)
	settings_item.collapsed = true

	tree.item_selected.connect(item_was_selected)
	
	
func item_was_selected():
	var tree_item = tree.get_selected()
	
	for item: TreeItem in items:
		if item != tree_item && item != tree_item.get_parent() && item.collapsed == false: item.collapsed = true
		
		if item == tree_item && item.collapsed == true:
			tree_item.set_collapsed(false)

	match tree_item.get_text(0):
		"Story Mode":
			pass
