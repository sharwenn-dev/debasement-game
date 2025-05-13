extends CSGBox3D

@onready var player = get_tree().get_first_node_in_group("Player")
@onready var data = player.data

@export var dialogue = [
	"GURT: YO",
	"you wouldn't get it YO",
	"you're not even GURT: YO",
	"NO DIALOGUE"
]

func interact():
	data.hunger = clamp(data.hunger + 30, 0, data.max_hunger)
	queue_free()
