extends BaseItem

@export var item_name = "Flesh Bandage"

@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	check_origin()

func activate():
	data.health = clamp(data.health + 20, 0, data.max_health)
	queue_free()
