class_name Spawn_manager extends Node

#temp
@export var explosion_scene: PackedScene

var oneoff_random_spawn_data: Resource = load("res://resources/spawn_data/oneoff_random_spawn_data.tres")
#Pickups:
var xp_orb_blue: PackedScene = load("res://scenes/game_objects/pickups/experience_orb/experience_orb_blue.tscn")
var xp_orb_yellow: PackedScene = load("res://scenes/game_objects/pickups/experience_orb/experience_orb_yellow.tscn")
var xp_orb_red: PackedScene = load("res://scenes/game_objects/pickups/experience_orb/experience_orb_red.tscn")
var xp_orbs: Array[PackedScene] = [xp_orb_blue, xp_orb_yellow, xp_orb_red]
var health_pack_scene = load("res://scenes/game_objects/pickups/health_pack/health_pack.tscn")
var rocket_scene = load("res://scenes/game_objects/rocket/rocket.tscn")

signal object_destroyed_signal(kill_count)

var spawn_datas: Array

var spawned_objects: Array
var spawned_weapons: Array
var spawned_pickups: Array
var spawned_effects: Array

var data_timers: Array[Timer]

#Destructable_objects:
var crate_scene: PackedScene = load("res://scenes/game_objects/crate/crate.tscn")

var kill_count = 0

func _ready():
	App.spawn_manager = self
	App.reset_game.connect(reset_spawn_manager)

func _process(_delta):
	if !spawn_datas.is_empty():
		for data in spawn_datas:
			if data.ready: process_data(data)
	
	
func reset_spawn_manager():
	spawn_datas = []
	kill_count = 0
	clear_spawns()
	
	
func clear_spawns():
	for object in spawned_objects:
		if object != null: object.queue_free()
	spawned_objects = []

	for weapon in spawned_weapons:
		if weapon != null: weapon.queue_free()	
	spawned_weapons = []

	for pickup in spawned_pickups:
		if pickup != null: pickup.queue_free()	
	spawned_pickups = []
	
	for effect in spawned_effects:
		if effect != null: effect.queue_free()
	spawned_effects = []
	
	
func add_data(data: Spawn_data):
	spawn_datas.append(data)
	#if current_command == null: current_command = command
	if data.associated_objective != null: 
		data.associated_objective = data.associated_objective.duplicate()
		data.associated_objective.objective_complete_signal.connect(data.clear_associated_objective,CONNECT_ONE_SHOT)
		
	var data_timer = Timer.new()
	add_child(data_timer)
	if data.total_time_in_minutes == 0: data.total_time_in_minutes = (60 * 100)
	data_timer.start(data.total_time_in_minutes)
	data.associated_timer = data_timer


func process_data(data: Spawn_data):
	data.ready = false
	match data.how_to_spawn:
		Spawn_data.How_to_spawn.RANDOM:
			spawn_random(data)
					
		Spawn_data.How_to_spawn.BURST:
			spawn_burst(data)
	
	if data.quantity_variation_behavior == Spawn_data.Quantity_variation_behavior.DYNAMIC:
		var seconds_passed = data.associated_timer.wait_time - data.associated_timer.time_left
		if int(seconds_passed) > data.quantity_change_start_seconds:
			data.quantity_change_start_seconds += data.quantity_change_increase_seconds
			data.quantity_per_wave += data.quantity_change_amount
			
					
	print("Time: ", int(data.associated_timer.wait_time - data.associated_timer.time_left), " Qty: ", data.quantity_per_wave, " Next Change: ", data.quantity_change_start_seconds)
	
	match data.wave_behavior:
		Spawn_data.Wave_behavior.TIMER_BASED:
			var seconds_passed = data.associated_timer.wait_time - data.associated_timer.time_left
			if int(seconds_passed) > data.behavior_change_start_amount:
				data.behavior_change_start_amount += data.behavior_change_start_increase

				match data.wave_behavior_variation:
					Spawn_data.Wave_behavior_variation.INCREASING:
						data.seconds_between_waves += data.behavior_change_amount
					Spawn_data.Wave_behavior_variation.DECREASING:
						data.seconds_between_waves -= data.behavior_change_amount
						if data.seconds_between_waves < 1: data.seconds_between_waves = 1
			print("Time: ", int(data.associated_timer.wait_time - data.associated_timer.time_left), " SBW: ", data.seconds_between_waves, " Next Change: ", data.behavior_change_start_amount)
			
		Spawn_data.Wave_behavior.KILL_BASED:
			if kill_count >= data.data.behavior_variation_start:
				match data.wave_behavior_variation:
					Spawn_data.Wave_behavior_variation.INCREASING:
						data.kill_target += int(data.behavior_variation_amount)
					Spawn_data.Wave_behavior_variation.DECREASING:
						data.kill_target -= int(data.behavior_variation_amount)
						if data.kill_target < 1: data.seconds_between_waves = 1
		
	match data.repeat_until:
		Spawn_data.Repeat_until.INFINITE:
			await get_tree().create_timer(data.seconds_between_waves).timeout
			data.ready = true
			return
		Spawn_data.Repeat_until.DEFINED:
			if data.number_of_waves > 0:
				await get_tree().create_timer(data.seconds_between_waves).timeout
				data.number_of_waves -= 1
				data.ready = true
				return
		Spawn_data.Repeat_until.OBJECTIVE_COMPLETE:
			if data.associated_objective != null:
				await get_tree().create_timer(data.seconds_between_waves).timeout
				data.ready = true
				return
		Spawn_data.Repeat_until.TIMER_FINISHED:
				if data.associated_timer.time_left > 0:
					await get_tree().create_timer(data.seconds_between_waves).timeout
					data.ready = true
					return
	
	data.associated_timer.queue_free()
	spawn_datas.erase(data)
	pass


func spawn_random(data: Spawn_data):
	for n in data.quantity_per_wave:
		var spawn_roll = randi_range(1, 100)
		#var new_spawn_select = command.possible_enemies.pick_random()
		
		var lowest: Spawn_module
		for module: Spawn_module in data.who_to_spawn:			
			if spawn_roll <= module.spawn_probability + App.difficulty_factor:
				if lowest == null: lowest = module
				elif module.spawn_probability < lowest.spawn_probability: lowest = module
				
		var new_spawn = lowest.scene_to_spawn.instantiate()
		new_spawn.loot_module_array = lowest.loot_module_array
		add_child(new_spawn)
		spawned_objects.append(new_spawn)
		new_spawn.spawn_manager = self as Spawn_manager
		
		new_spawn.global_position = pick_location()
		if App.player != null: new_spawn.object_direction = new_spawn.global_position.direction_to(App.player.global_position)
		
		new_spawn.health_component.died.connect(object_destroyed)
		if data.associated_objective != null: data.associated_objective.connect_signal(new_spawn.health_component.died)


func spawn_burst(data: Spawn_data):	
	var amount = randf_range(2, 4)
	var arrangement1: Array[Vector2] = [Vector2(1, 1), Vector2(-1, -1), Vector2(-1, 1), Vector2(1, -1)]
	var arrangement2: Array[Vector2] = [Vector2(1, 0), Vector2(0, 1), Vector2(-1, 0), Vector2(0, -1)]
	var arrangements: Array[Array] = [arrangement1, arrangement2]

	var asteroids: Array[Asteroid] = []
	for number in amount:
		
		var spawn_roll = randi_range(1, 100)
		#var new_spawn_select = command.possible_enemies.pick_random()
		
		var lowest: Spawn_module
		for module: Spawn_module in data.who_to_spawn:			
			if spawn_roll <= module.spawn_probability:
				if lowest == null: lowest = module
				elif module.spawn_probability < lowest.spawn_probability: lowest = module
				
		var new_spawn = lowest.scene_to_spawn.instantiate()
		new_spawn.loot_module_array = lowest.loot_module_array
		add_child(new_spawn)
		spawned_objects.append(new_spawn)
		asteroids.append(new_spawn)
		new_spawn.spawn_manager = self
		
	var arrange: Array[Vector2] = arrangements.pick_random().duplicate()
	
	for asteroid in asteroids:
		var position = arrange.pick_random()
		arrange.erase(position)
		
		asteroid.position = data.defined_spawn_position + Vector2(position.x * (15 * asteroid.size_multiplier), position.y * (15 * asteroid.size_multiplier))
		asteroid.object_direction = position
		asteroid.object_speed = 75
		
		asteroid.health_component.died.connect(object_destroyed)
		if data.associated_objective != null:
			data.associated_objective.connect_signal(asteroid.health_component.died)
	

func pick_location():
	var rand = randi_range(1, 4)
	var location = Vector2.ZERO
	match rand:
		1: location = Vector2(randf_range(App.play_area_x_min, App.play_area_x_max), randf_range(App.play_area_y_min - 500, App.play_area_y_min - 100))
		2: location = Vector2(randf_range(App.play_area_x_min, App.play_area_x_max), randf_range(App.play_area_y_max + 100, App.play_area_y_max + 500))
		3: location = Vector2(randf_range(App.play_area_x_min - 500, App.play_area_x_min - 100), randf_range(App.play_area_y_min, App.play_area_y_max))
		4: location = Vector2(randf_range(App.play_area_x_max + 100, App.play_area_x_max + 500), randf_range(App.play_area_y_min, App.play_area_y_max))
	return location


func object_destroyed(health_amt: int):
	kill_count += 1
	object_destroyed_signal.emit(kill_count)
	add_score(health_amt)
	
	
func add_score(health_amt: int):
	App.update_score(health_amt)
	
	
func prep_loot_crate():
	var loot_array: Array[Loot_module] = []
	
	#Checks if player needs healing:
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
	var spawn_module_array: Array[Spawn_module] = []
	spawn_module_array.append(spawn_module)
	prepare_oneshot_spawn_data(spawn_module_array)
	
	
func prepare_oneshot_spawn_data(spawn_module_array: Array[Spawn_module]):
	var new_spawn_data: Spawn_data = oneoff_random_spawn_data.duplicate()
	new_spawn_data.who_to_spawn = spawn_module_array
	add_data(new_spawn_data)
	

func spawn_expolsion(location):
	deferred_explosion.call_deferred(location)
	
	
func deferred_explosion(location):
	var explosion_instance = explosion_scene.instantiate() as Node2D
	add_child(explosion_instance)
	explosion_instance.global_position = location

	
func spawn_rocket(location, rotation):
	var rocket_instance = rocket_scene.instantiate() as Node2D
	get_tree().root.add_child(rocket_instance)
	spawned_weapons.append(rocket_instance)
	rocket_instance.global_position = location
	rocket_instance.global_rotation = rotation
	
	
func spawn_status_effect_particles(input, color: Color, position):
	var stat_effect = App.stat_change_particles.instantiate() as Stat_particles
	add_child(stat_effect)
	stat_effect.set_label(input, color)
	stat_effect.position = position
	stat_effect.restart()
	spawned_effects.append(stat_effect)
	await stat_effect.finished
	spawned_effects.erase(stat_effect)
	stat_effect.queue_free()
