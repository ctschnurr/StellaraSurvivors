extends Node
class_name Enemy_manager

var game_manager: Game_manager

@export var asteroid_small: PackedScene
@export var asteroid_medium: PackedScene
@export var asteroid_large: PackedScene

@export var blaster_bolt_scene: PackedScene

enum Enemy_type{ASTEROID_SMALL, ASTEROID_MEDIUM, ASTEROID_LARGE}
@onready var enemy_dictionary: Dictionary = {"ASTEROID_SMALL": asteroid_small, "ASTEROID_MEDIUM": asteroid_medium, "ASTEROID_LARGE": asteroid_large}

const asteroid_spawn_xRange = [30, 1250]
const asteroid_spawn_yRange = [-300, 0]

	#if global_position.x > 1250: global_position.x = 1250
	#if global_position.x < 30: global_position.x = 30
	#if global_position.y > 690: global_position.y = 690
	#if global_position.y < 30: global_position.y = 30

var location_mod_amount = 300

var spawn_commands: Array
var current_command: Spawn_command
var enemies: Array
var bolts: Array
var time_tracker: int = 0

var command_timer: Timer

func _ready():
	App.enemy_manager = self
	App.reset_game.connect(reset_enemy_manager)


func reset_enemy_manager():
	clear_enemies()


func _process(_delta):
	if !spawn_commands.is_empty():
		for command in spawn_commands:
			if command.ready: process_command(command)


func add_command(command: Spawn_command):
	spawn_commands.append(command)
	if current_command == null: current_command = command
	if command.associated_objective != null: 
		command.associated_objective = command.associated_objective.duplicate()
		command.associated_objective.objective_complete_signal.connect(command.clear_associated_objective,CONNECT_ONE_SHOT)
		
	if command.repeat_mode == Spawn_command.Repeat_mode.ACCELERATING:
		command_timer = Timer.new()
		add_child(command_timer)
		command_timer.start(command.repeat_timer)
		var times_to_spawn = ((command.repeat_timer / 60) * 15)
		command.repeat_delay = command.repeat_timer / times_to_spawn


func process_command(command: Spawn_command):
	command.ready = false
	match command.spawn_positioning:
		Spawn_command.Spawn_positioning.SCATTER:	
			spawn_scatter(command)
					
		Spawn_command.Spawn_positioning.ASTEROID_BURST:
			spawn_asteroid_burst(command)
			
	match command.repeat_mode:
		Spawn_command.Repeat_mode.STEADY:
			pass
			
		Spawn_command.Repeat_mode.ACCELERATING:
			var minutes = (command_timer.wait_time - command_timer.time_left) / 60
			if int(minutes) > time_tracker:
				time_tracker = int(minutes)
				command.spawn_amount += 1
			
			
	match command.repeat_state:
		Spawn_command.Repeat_state.INFINITE:
			await get_tree().create_timer(command.repeat_delay).timeout
			command.ready = true
			return
		Spawn_command.Repeat_state.MULTIPLE:
			if command.repeat_amount > 0:
				await get_tree().create_timer(command.repeat_delay).timeout
				command.repeat_amount -= 1
				command.ready = true
				return
		Spawn_command.Repeat_state.OBJECTIVE:
			if command.associated_objective != null:
				await get_tree().create_timer(command.repeat_delay).timeout
				command.ready = true
				return
		Spawn_command.Repeat_state.TIMER:
				await get_tree().create_timer(command.repeat_delay).timeout
				command.ready = true
				return
	
	spawn_commands.erase(command)
	pass
	
	
func clear_enemies():
	for enemy in enemies:
		if enemy != null: enemy.queue_free()
	enemies = []
	spawn_commands = []
	current_command = null
	for bolt in bolts:
		if bolt != null: bolt.queue_free()	
	bolts = []
	time_tracker = 0
	

func spawn_scatter(command: Spawn_command):
	var spawn_location: Vector2 = pick_location()
	for n in command.spawn_amount:
		var new_asteroid_select = command.possible_enemies.pick_random()
		var this_enum = Enemy_type.keys()[new_asteroid_select]
		var enemy_instance = enemy_dictionary[this_enum].instantiate() as Asteroid
		
		add_child(enemy_instance)
		enemies.append(enemy_instance)
		enemy_instance.enemy_manager = self
		
		enemy_instance.global_position = spawn_location
		if App.player != null: enemy_instance.asteroid_direction = spawn_location.direction_to(App.player.global_position)
		
		enemy_instance.health_component.died.connect(add_score)
		if command.associated_objective != null:
			command.associated_objective.connect_signal(enemy_instance.health_component.died)
	
	
func spawn_asteroid_burst(command: Spawn_command):	
	var amount = randf_range(2, 4)
	var arrangement1: Array[Vector2] = [Vector2(1, 1), Vector2(-1, -1), Vector2(-1, 1), Vector2(1, -1)]
	var arrangement2: Array[Vector2] = [Vector2(1, 0), Vector2(0, 1), Vector2(-1, 0), Vector2(0, -1)]
	var arrangements: Array[Array] = [arrangement1, arrangement2]
	
	var asteroids: Array[Asteroid] = []
	for number in amount:
		var new_asteroid_select = command.possible_enemies.pick_random()
		var this_enum = Enemy_type.keys()[new_asteroid_select]
		var new_asteroid = enemy_dictionary[this_enum].instantiate() as Asteroid
		new_asteroid.enemy_manager = self
		enemies.append(new_asteroid)
		asteroids.append(new_asteroid)
		
	var arrange: Array[Vector2] = arrangements.pick_random().duplicate()
	
	for asteroid in asteroids:
		var position = arrange.pick_random()
		arrange.erase(position)
		
		asteroid.position = command.spawn_location + Vector2(position.x * (15 * asteroid.size_multiplier), position.y * (15 * asteroid.size_multiplier))
		asteroid.asteroid_direction = position
		asteroid.asteroid_speed = 75
		add_child(asteroid)
		asteroid.health_component.died.connect(add_score)
		if current_command.associated_objective != null:
			current_command.associated_objective.connect_signal(asteroid.health_component.died)


func spawn_blaster_bolt(location, rotation):
	var blaster_bolt_instance = blaster_bolt_scene.instantiate() as Node2D
	get_tree().root.add_child(blaster_bolt_instance)
	bolts.append(blaster_bolt_instance)
	blaster_bolt_instance.global_position = location
	blaster_bolt_instance.global_rotation = rotation


func pick_location():
	var rand = randi_range(1, 4)
	var location = Vector2.ZERO
	match rand:
		1: location = Vector2(randi_range(App.play_area_x_min, App.play_area_x_max), randi_range(App.play_area_y_min - 400, App.play_area_y_min))
		2: location = Vector2(randi_range(App.play_area_x_min, App.play_area_x_max), randi_range(App.play_area_y_max, App.play_area_y_max + 400))
		3: location = Vector2(randi_range(App.play_area_x_min - 400, App.play_area_x_min), randi_range(App.play_area_y_min, App.play_area_y_max))
		4: location = Vector2(randi_range(App.play_area_x_max, App.play_area_x_max + 400), randi_range(App.play_area_y_min, App.play_area_y_max))
	return location


func add_score(health_amt: int):
	App.update_score(health_amt)
	pass
	
