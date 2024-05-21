class_name Experience_orb extends CharacterBody2D
var xp_amount: float = 1
@onready var sprite = $Sprite2D
var player: Player

signal collected(xp: float)

func _ready():
	$Area2D.area_entered.connect(on_area_entered)
	player = App.player
	
	
func on_area_entered(_area_entered):
	collected.emit(xp_amount)
	queue_free()
	
	
func _process(delta):
	if player == null: return
	var distance_to_player: float = global_position.distance_to(player.global_position)
	var direction_to_player: Vector2 = global_position.direction_to(player.global_position)
	
	if distance_to_player < App.orb_attract_distance:
		var target_velocity = direction_to_player * (App.orb_attract_distance / distance_to_player * 25)
			
		velocity = velocity.lerp(target_velocity, 1 - exp(-delta * 5))
		move_and_slide()
		
