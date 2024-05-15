class_name Spawn_command extends Resource
	
enum Spawn_positioning{SCATTER,SQUAD,ASTEROID_BURST}
enum Repeat_state{ONCE,MULTIPLE,INFINITE,OBJECTIVE}
enum Repeat_mode{STEADY,RANDOM,ACCELERATING}

@export var possible_enemies: Array[Enemy_manager.Enemy_type] = []
@export var repeat_state: Repeat_state = Repeat_state.ONCE
@export var repeat_mode: Repeat_mode = Repeat_mode.STEADY
@export var repeat_delay: int = 0
@export var repeat_amount: int = 0
@export var ready: bool = true
@export var enemy_type: Array[PackedScene]
@export var spawn_amount: int
@export var spawn_positioning: Spawn_positioning = Spawn_positioning.SCATTER
@export var associated_objective: Objective
@export var spawn_location: Vector2 = Vector2.ZERO

func clear_associated_objective(_objective: Objective):
	associated_objective = null
