extends BaseItem

@export var item_name = "Flesh Bandage"
@onready var heal = preload("res://assets/sound/sfx/heal.wav")

@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	check_origin()

func activate():
	data.health = clamp(data.health + 20, 0, data.max_health)
	player.play_sound(heal, player.aud1)
	queue_free()
