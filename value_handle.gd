extends Node

@onready var player = get_tree().get_first_node_in_group("Player")

var values = {
	"killing": [3, false],
	"starving": [30, false],
	"falling": [40, false],
}

func value_reset():
	values.killing[1] = false
	values.starving[1] = false
	values.falling[1] = false

func add_value(name):
	player.data.values.append(name)
	var value_path = load("res://values/" + name + ".tscn")
	var value_scene = value_path.instantiate()
	player.add_child(value_scene)
	value_scene.initialize()
	return

func _process(delta: float) -> void:
	player = get_tree().get_first_node_in_group("Player")
	if player != null:
		var Pvalue = player.data.value
		Pvalue = player.data.value
		if Pvalue.killing >= values.killing[0] and not values.killing[1]\
		and player.data.can_get_value:
			values.killing[1] = true
			add_value("killing")
		if Pvalue.starving >= values.starving[0] and not values.starving[1]\
		and player.data.can_get_value:
			values.starving[1] = true
			add_value("starving")
		if Pvalue.falling >= values.falling[0] and not values.falling[1]\
		and player.data.can_get_value:
			values.falling[1] = true
			add_value("falling")
