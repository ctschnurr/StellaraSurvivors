extends CanvasLayer

signal upgrade_selected(upgrade: Player_upgrade)

@export var upgrade_card_scene: PackedScene
@export var card_container: HBoxContainer

func _ready():
	get_tree().paused = true


func set_player_upgrades(upgrades: Array[Player_upgrade], current_upgrades: Dictionary):
	for upgrade in upgrades:
		var new_card = upgrade_card_scene.instantiate() as Upgrade_card
		card_container.add_child(new_card)
		new_card.setup_card(upgrade)
		new_card.selected.connect(upgrade_clicked.bind(upgrade))
		
		
func upgrade_clicked(upgrade: Player_upgrade):
	upgrade_selected.emit(upgrade)
	get_tree().paused = false
	queue_free()
