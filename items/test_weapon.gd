extends CSGBox3D

@onready var player = get_tree().get_first_node_in_group("Player")
@onready var data = player.data

@onready var hitbox = preload("res://hit_box.tscn")

var floor_rotation = Vector3(
	randf_range(-PI, PI),
	randf_range(-PI, PI), # THIS IS SO WEIRD
	randf_range(-PI, PI)
)
var pickup_rotation = Vector3(0, 0, 0)

var can_be_used = true

func _ready() -> void:
	rotation_degrees = floor_rotation

func activate():
	can_be_used = false
	#data.hunger = clamp(data.hunger + 20, 0, data.max_hunger)
	#queue_free()
	var hitbox_instance = hitbox.instantiate()
	player.hitbox_pos.add_child(hitbox_instance)
	hitbox_instance.damage = 50
	hitbox_instance.global_position = player.hitbox_pos.global_position
	var timer = get_tree().create_timer(0.1)
	await timer.timeout
	hitbox_instance.queue_free()
	can_be_used = true
