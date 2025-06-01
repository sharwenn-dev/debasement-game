extends BaseItem

@export var item_name = "Leftovers"

@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	check_origin()

func activate():
	data.hunger = clamp(data.hunger + 30, 0, data.max_hunger)
	queue_free()
