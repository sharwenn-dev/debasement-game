class_name BaseItem extends CSGMesh3D

@onready var player = get_tree().get_first_node_in_group("Player")
@onready var data = player.data

@export var rand_rotation = true
var current_scene = null
var origin_scene = null

func _ready() -> void:
	current_scene = get_tree().current_scene
	origin_scene = current_scene
	
	if rand_rotation:
		rotation = Vector3(
			randf_range(0.0, TAU),
			randf_range(0.0, TAU),
			randf_range(0.0, TAU)
		)

func check_origin():
	current_scene = get_tree().current_scene
	if origin_scene != current_scene:
		queue_free()
