class_name Event_manager extends Node


func _ready():
	App.event_manager = self
	App.reset_game.connect(reset_event_manager)
	App.spawn_manager.object_destroyed_signal.connect(process_kill_count)


func process_kill_count(kill_count):
	var kill_count_conversion: float = kill_count / App.CRATE_EVENT_TARGET
	var is_conversion_even = is_equal_approx(float(kill_count_conversion), int(kill_count_conversion))
	#print("Kill Count: ", kill_count, " Devided by ", App.CRATE_EVENT_TARGET, ": ", test_div, " Devides by ", App.CRATE_EVENT_TARGET, ": ", test_bool)
	if is_conversion_even == true:
		App.spawn_manager.prep_loot_crate()
		print("Event Triggered")


func reset_event_manager():
	pass
