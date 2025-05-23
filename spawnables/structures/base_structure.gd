class_name BaseStructure extends Node3D

@onready var player = get_tree().get_first_node_in_group("Player")
@onready var data = player.data

var current_scene = null
var origin_scene = null

func _ready() -> void:
	current_scene = get_tree().current_scene
	origin_scene = current_scene

func _process(delta: float) -> void:
	check_origin()

func check_origin():
	current_scene = get_tree().current_scene
	if origin_scene != current_scene:
		queue_free()
