class_name Upgrade_manager extends Node

@export var upgrade_pool: Array[Player_upgrade]
@export var experience_manager: Experience_manager
@export var upgrade_screen_scene: PackedScene

var current_pool

var current_upgrades = {}

func _ready():
	current_pool = upgrade_pool.duplicate()
	experience_manager.level_up.connect(on_level_up)
	App.upgrade_manager = self
	App.reset_game.connect(reset_upgrade_manager)
	
	
func on_level_up(_current_level: int):
	if current_pool.size() == 0:
		return	
		
	var upgrade_screen = upgrade_screen_scene.instantiate()
	add_child(upgrade_screen)
	upgrade_screen.set_player_upgrades(current_pool, current_upgrades as Dictionary)
	upgrade_screen.upgrade_selected.connect(on_upgrade_selected)
	

func apply_upgrade(upgrade: Player_upgrade):
		
	var has_upgrade = current_upgrades.has(upgrade.id)
	if !has_upgrade:
		current_upgrades[upgrade.id] = {
			"resource": upgrade,
			"quantity": 1
		}
	else:
		current_upgrades[upgrade.id]["quantity"] += 1
		if current_upgrades[upgrade.id]["quantity"] == upgrade.max_lvl:
			current_pool.erase(upgrade)
					
	App.player.update_abilities(upgrade, current_upgrades)


func on_upgrade_selected(upgrade: Player_upgrade):
	apply_upgrade(upgrade)
	

func reset_upgrade_manager():
	current_upgrades = {}
	current_pool = upgrade_pool.duplicate()
