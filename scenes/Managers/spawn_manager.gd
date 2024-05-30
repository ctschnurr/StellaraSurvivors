class_name Spawn_manager extends Node

@export var spawn_command_resource = load("res://Spawn_command.gd")
@export var possible_spawn_commands:Array[Spawn_data] = []
#Pickups:
var xp_orb_blue: PackedScene = load("res://scenes/game_objects/experience_orb/experience_orb_blue.tscn")
var xp_orb_yellow: PackedScene = load("res://scenes/game_objects/experience_orb/experience_orb_yellow.tscn")
var xp_orb_red: PackedScene = load("res://scenes/game_objects/experience_orb/experience_orb_red.tscn")
var xp_orbs: Array[PackedScene] = [xp_orb_blue, xp_orb_yellow, xp_orb_red]
var health_pack_scene = load("res://scenes/game_objects/health_pack/health_pack.tscn")

var spawn_commands: Array

#Destructable_objects:
var crate_scene: PackedScene = load("res://scenes/game_objects/crate/crate.tscn")

func _ready():
	App.spawn_manager = self
	
	
func spawn_status_effect_particles(input, color: Color, position):
	var stat_effect = App.stat_change_particles.instantiate() as Stat_particles
	add_child(stat_effect)
	stat_effect.set_label(str(input), color)
	stat_effect.position = position
	stat_effect.restart()
	await stat_effect.finished
	stat_effect.queue_free()
	
	
func prep_loot_crate():
	var loot_array: Array[Loot_module]
	var player_health_percent = App.player.get_health()
	if player_health_percent < 1:
		var health_pack_module = Loot_module.new()
		health_pack_module.loot_scene = health_pack_scene
		health_pack_module.loot_drop_probability = 100
		loot_array.append(health_pack_module)
		
	var extra_xp_number = randi_range(3, 5) + App.difficulty_factor
	for number in extra_xp_number:
		var extra_xp_module = Loot_module.new()
		extra_xp_module.loot_scene = App.spawn_manager.xp_orbs.pick_random()
		extra_xp_module.loot_drop_probability = 100
		loot_array.append(extra_xp_module)
		
	var spawn_module = Spawn_module.new()
	spawn_module.scene_to_spawn = crate_scene
	spawn_module.spawn_probability = 100
	spawn_module.loot_module_array = loot_array
	
	
func spawn_single_object(spawn_module: Spawn_module):
	pass


func process_command(data: Spawn_data):
	data.ready = false
	match data.how_to_spawn:
		Spawn_data.How_to_spawn.RANDOM:
			print("scatter")
			#spawn_scatter(data)
					
		Spawn_data.How_to_spawn.BURST:
			print("burst")
			#spawn_asteroid_burst(data)
			
			
	match data.repeat_until:
		Spawn_data.Repeat_until.INFINITE:
			await get_tree().create_timer(data.repeat_delay).timeout
			data.ready = true
			return
		Spawn_data.Repeat_until.DEFINED:
			if data.number_of_waves > 0:
				await get_tree().create_timer(data.repeat_delay).timeout
				data.number_of_waves -= 1
				data.ready = true
				return
		Spawn_data.Repeat_until.OBJECTIVE_COMPLETE:
			if data.associated_objective != null:
				await get_tree().create_timer(data.repeat_delay).timeout
				data.ready = true
				return
		Spawn_data.Repeat_until.TIMER_FINISHED:
				await get_tree().create_timer(data.repeat_delay).timeout
				data.ready = true
				return
	
	spawn_commands.erase(data)
	pass
