extends CSGBox3D

@onready var player = get_tree().get_first_node_in_group("Player")
@onready var data = player.data

func activate():
	data.health = clamp(data.health + 20, 0, data.max_health)
	queue_free()
