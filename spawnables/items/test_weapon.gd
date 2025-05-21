extends BaseItem

@onready var hitbox = preload("res://hit_box.tscn")

var can_be_used = true

@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	check_origin()

func activate():
	can_be_used = false
	#data.hunger = clamp(data.hunger + 20, 0, data.max_hunger)
	#queue_free()
	var hitbox_instance = hitbox.instantiate()
	player.hitbox_pos.add_child(hitbox_instance)
	hitbox_instance.damage = 10
	hitbox_instance.global_position = player.hitbox_pos.global_position
	var timer = get_tree().create_timer(0.1)
	await timer.timeout
	hitbox_instance.queue_free()
	can_be_used = true
