extends Node3D

@onready var spawn_folder = "res://spawnables/"

enum Weight {
	COMMON = 100,
	UNCOMMON = 30,
	RARE = 20
}

@export_category("Folder Weights")
@export var folders_enabled = {
	"items": true,
	"hazards": true,
	"structures": true,
	"creatures": true
}

@export var folder_weights = {
	"items": Weight.COMMON,
	"hazards": Weight.UNCOMMON,
	"structures": Weight.RARE,
	"creatures": Weight.RARE
}

@export_category("Spawnables")
@export var items = {
	"food_item": Weight.COMMON,
	"health_item": Weight.UNCOMMON,
	"test_weapon": Weight.RARE
}

@export var hazards = {
	"test_hazard": Weight.UNCOMMON
}

@export var structures = {
	"test_structure": Weight.RARE
}

@export var creatures = {
	"boulder": Weight.RARE,
	"mimic": Weight.UNCOMMON,
	"skitter": Weight.COMMON,
	"base_human": Weight.COMMON
}

func _ready() -> void:
	spawn_random_poi()

func pick_weighted_entry(weighted_dict: Dictionary) -> String:
	var total_weight = 0
	for value in weighted_dict.values():
		total_weight += value

	if total_weight <= 0:
		return ""

	var pick = randi() % total_weight
	var accum = 0

	for key in weighted_dict.keys():
		accum += weighted_dict[key]
		if pick < accum:
			return key
	
	return ""

func choose_random_folder() -> String:
	var usable = {}
	for folder in folder_weights.keys():
		if folders_enabled.get(folder, false):
			usable[folder] = folder_weights[folder]
	return pick_weighted_entry(usable)

func get_folder_spawnables(folder: String) -> Dictionary:
	match folder:
		"items": return items
		"hazards": return hazards
		"structures": return structures
		"creatures": return creatures
	return {}

func choose_random_spawnable() -> Dictionary:
	var folder = choose_random_folder()
	if folder == "":
		return {}

	var spawnable_dict = get_folder_spawnables(folder)
	if spawnable_dict.is_empty():
		return {}

	var chosen_spawnable = pick_weighted_entry(spawnable_dict)
	if chosen_spawnable == "":
		return {}

	return {
		"folder": folder,
		"scene_name": chosen_spawnable
	}

func spawn_random_poi():
	var choice = choose_random_spawnable()
	if choice.is_empty():
		return

	var path = spawn_folder + choice.folder + "/" + choice.scene_name + ".tscn"
	var scene = load(path)
	if scene == null:
		return

	var instance = scene.instantiate()
	add_child(instance)  

	await get_tree().process_frame  

	instance.global_position = global_position + Vector3(0, 0.05, 0)
