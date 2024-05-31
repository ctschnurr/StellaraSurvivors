class_name Spawn_data extends Resource

#spawn handling:
@export_group("Spawn Settings:")
@export var who_to_spawn: Array[Spawn_module] = []
@export var who_description: String = "object"
var associated_timer: Timer

enum How_to_spawn{RANDOM,BURST,SQUAD}
@export var how_to_spawn: How_to_spawn = How_to_spawn.RANDOM

enum Where_to_spawn{OUTSIDE_PLAY_AREA, DEFINED}
@export var where_to_spawn: Where_to_spawn = Where_to_spawn.OUTSIDE_PLAY_AREA
@export_subgroup("- If 'Defined':")
@export var defined_spawn_position: Vector2

@export_group("Spawn Quantity Settings:")
@export var quantity_per_wave: int = 1

enum Quantity_variation_behavior{STATIC, DYNAMIC}
@export var quantity_variation_behavior: Quantity_variation_behavior = Quantity_variation_behavior.STATIC

@export_subgroup("If 'Dynamic':")
@export var quantity_change_start_seconds: int = 1
@export var quantity_change_increase_seconds: int = 1
@export var quantity_change_amount: int = 1


#processing and adjusting repeating:

@export_group("Repeat Settings:")

enum Repeat_until{INFINITE,DEFINED,OBJECTIVE_COMPLETE,TIMER_FINISHED}
@export var repeat_until: Repeat_until = Repeat_until.INFINITE

@export_subgroup("- If 'Defined':")
@export var number_of_waves: int = 1

@export_subgroup("- If 'Objective Complete':")
@export var tracked_objective: Objective
var objective_complete = false

@export_subgroup("- If 'Timer Finished':")
@export var total_time_in_minutes: float = 0

@export_group("Wave Settings:")

enum Wave_behavior{TIMER_BASED, KILL_BASED}
@export var wave_behavior: Wave_behavior = Wave_behavior.TIMER_BASED

enum Wave_behavior_variation{STEADY,INCREASING,DECREASING}

@export var wave_behavior_variation: Wave_behavior_variation = Wave_behavior_variation.STEADY

@export_subgroup("- If On Timer Based:")
@export var seconds_between_waves: float = 0

@export_subgroup("- If On Kill Based:")
@export var kill_target: int = 0

@export_subgroup("- If Behavior Variation != Steady:")
## Input Time in Seconds or Kill Amount Reached when variation should start.
@export var behavior_variation_start: float = 0
## Input Time in Seconds or Kill Amount that should be deducted from wave goal.
@export var behavior_variation_amount: float = 0

@export_group("If spawns are tied to an objective:")

@export var associated_objective: Objective_data

var ready: bool = true

func clear_associated_objective(_objective: Objective):
	associated_objective = null
