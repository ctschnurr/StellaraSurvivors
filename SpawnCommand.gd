class_name Spawn_command extends Resource
	
enum Spawn_orientation{SCATTER,SQUAD}
enum Repeat_state{ONCE,MULTIPLE,INFINITE,OBJECTIVE}
enum Repeat_mode{STEADY,RANDOM,ACCELERATING}

@export var repeat_state: Repeat_state = Repeat_state.ONCE
@export var repeat_mode: Repeat_mode = Repeat_mode.STEADY
@export var repeat_delay: int = 0
@export var repeat_amount: int = 0
@export var ready: bool = true
@export var enemy_type: Array[PackedScene]
@export var spawn_amount: int
@export var spawn_orientation: Spawn_orientation
@export var associated_objective: Objective

func clear_associated_objective():
	associated_objective = null
