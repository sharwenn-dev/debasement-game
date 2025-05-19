extends Node

@onready var player = get_tree().get_first_node_in_group("Player")
@onready var value = player.data.value

var values = {
	"killing": [2, false],
	"starving": [30, false],
	"falling": [60, false],
}

func value_reset():
	values.killing[1] = false

func _process(delta: float) -> void:
	player = get_tree().get_first_node_in_group("Player")
	if player != null:
		if player.data.STATE == "dead":
			value_reset()
		if value.kills >= values.killing[0] and not values.killing[1]:
			player.data.values.append("killing")
			var value_path = load("res://values/killing.tscn")
			var value_scene = value_path.instantiate()
			player.add_child(value_scene)
			value_scene.initialize()
			values.killing[1] = true
