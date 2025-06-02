extends BaseItem

@export var item_name = "Leftovers"
@onready var eat = preload("res://assets/sound/sfx/eat.wav")

@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	check_origin()

func activate():
	data.hunger = clamp(data.hunger + 30, 0, data.max_hunger)
	player.play_sound(eat, player.aud1)
	queue_free()
