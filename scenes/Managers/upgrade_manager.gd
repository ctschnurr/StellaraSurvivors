extends Node

@export var upgrade_pool: Array[Player_upgrade]
@export var experience_manager: Experience_manager
@export var upgrade_screen_scene: PackedScene

var current_upgrades = {}

func _ready():
	experience_manager.level_up.connect(on_level_up)
	
	
func on_level_up(_current_level: int):
	if upgrade_pool.size() == 0:
		return	
		
	var upgrade_screen = upgrade_screen_scene.instantiate()
	add_child(upgrade_screen)
	upgrade_screen.set_player_upgrades(upgrade_pool, current_upgrades as Dictionary)
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
			upgrade_pool.erase(upgrade)
					
	 
	print(current_upgrades)
	App.player.update_abilities(upgrade, current_upgrades)


func on_upgrade_selected(upgrade: Player_upgrade):
	apply_upgrade(upgrade)
	

