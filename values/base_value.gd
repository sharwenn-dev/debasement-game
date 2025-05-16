class_name BaseValue extends Node3D

@onready var player = get_tree().get_first_node_in_group("Player")
@onready var data = player.data

var current_scene = null
var origin_scene = null

var initialized = false
@export var value_name = "" # ex: "YOU VALUE KILLING"

func _ready() -> void:
	current_scene = get_tree().current_scene
	origin_scene = current_scene

func check_origin():
	current_scene = get_tree().current_scene
	if origin_scene != current_scene:
		queue_free()
