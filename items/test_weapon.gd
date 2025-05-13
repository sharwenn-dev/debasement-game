extends CSGBox3D

@onready var player = get_tree().get_first_node_in_group("Player")
@onready var data = player.data

@onready var hitbox = preload("res://hit_box.tscn")

var can_be_used = true

func activate():
	can_be_used = false
	#data.hunger = clamp(data.hunger + 20, 0, data.max_hunger)
	#queue_free()
	var hitbox_instance = hitbox.instantiate()
	hitbox_instance.damage = 50
	hitbox_instance.global_position = player.hitbox_pos.global_position
	player.hitbox_pos.add_child(hitbox_instance)
	var timer = get_tree().create_timer(0.1)
	await timer.timeout
	hitbox_instance.queue_free()
	can_be_used = true
