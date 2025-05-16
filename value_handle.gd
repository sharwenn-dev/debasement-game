extends Node

@onready var player = get_tree().get_first_node_in_group("Player")

func _process(delta: float) -> void:
	player = get_tree().get_first_node_in_group("Player")
	if player != null:
		if player.data.value.kills >= 2:
			player.take_damage(1000, "visceral")
