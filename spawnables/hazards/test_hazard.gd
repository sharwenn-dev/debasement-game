extends Node3D

@onready var player = get_tree().get_first_node_in_group("Player")
@export var dmg = 5

var in_range = false
var last_hurt = 0.0
var time_to_hurt = 2.0

func _physics_process(delta: float) -> void:
	if last_hurt >= time_to_hurt:
		last_hurt = 0.0
		player.data.health -= dmg
	
	if in_range:
		last_hurt += delta
	else:
		last_hurt = 0.0

func _on_hazard_zone_body_entered(body: Node3D) -> void:
	if body == player:
		in_range = true
		player.SPEED -= 2.0


func _on_hazard_zone_body_exited(body: Node3D) -> void:
	if body == player:
		in_range = false
		player.SPEED += 2.0
