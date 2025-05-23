extends Node3D

@onready var spawn_folder = "res://spawnables/"

var chosen_folder = null
var chosen_array = null
var chosen_spawnable = null

# choosable folders in dictionary
@export var folders = [
	"items",
	"structures"
]

# items for each folder or very well designed for loop
@export var items = [
	"food_item",
	"health_item",
	"test_weapon"
]

@export var structures = [
	"test_hazard",
	"test_structure"
]

func _ready() -> void:
	spawn_spawnable()

func choose_spawnable():
	var rand_folder = randi_range(0, 1)
	if rand_folder == 0:
		chosen_folder = "items"
		chosen_array = items
	if rand_folder == 1:
		chosen_folder = "structures"
		chosen_array = structures
	var rand_spawnable = randi_range(0, len(chosen_array)-1)
	chosen_spawnable = chosen_array[rand_spawnable]

func spawn_spawnable():
	
	choose_spawnable()
	
	
	var spawn_path = load(spawn_folder + chosen_folder + "/"\
	+ chosen_spawnable + ".tscn")
	var spawn_scene = spawn_path.instantiate()
	get_tree().get_root().call_deferred("add_child", spawn_scene)
	await get_tree().create_timer(0.1).timeout
	spawn_scene.global_position = global_position
	spawn_scene.global_position.y += 0.05
