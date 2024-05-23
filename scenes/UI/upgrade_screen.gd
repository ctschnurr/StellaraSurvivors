extends CanvasLayer

signal upgrade_selected(upgrade: Player_upgrade)

@export var upgrade_card_scene: PackedScene
@export var card_container: HBoxContainer

func _ready():
	get_tree().paused = true


func set_player_upgrades(upgrades: Array[Player_upgrade], current_upgrades: Dictionary):
	var new_cards: Array
	var choices = upgrades.duplicate()
	while choices.size() > App.UPGRADES_PER_LEVEL:
		choices.erase(choices.pick_random())
	choices.shuffle()
	for upgrade in choices:
		var new_card = upgrade_card_scene.instantiate() as Upgrade_card
		card_container.add_child(new_card)
		var has_upgrade = current_upgrades.has(upgrade.id)
		var upgrade_level = 1
		if has_upgrade: upgrade_level = current_upgrades[upgrade.id]["quantity"] + 1
		new_card.setup_card(upgrade, upgrade_level)
		new_card.selected.connect(upgrade_clicked.bind(upgrade))
		
		new_cards.append(new_card)
		
	new_cards[0].panel.grab_focus()
		
func upgrade_clicked(upgrade: Player_upgrade):
	upgrade_selected.emit(upgrade)
	get_tree().paused = false
	queue_free()
