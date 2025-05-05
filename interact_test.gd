extends CSGBox3D

@onready var player = get_tree().get_first_node_in_group("Player")

func interact():
	player.data.hunger += 30
	queue_free()
