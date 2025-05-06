extends CSGBox3D

@onready var player = get_tree().get_first_node_in_group("Player")
@onready var data = player.data

func activate():
	data.hunger = clamp(data.hunger + 30, 0, data.max_hunger)
	queue_free()
