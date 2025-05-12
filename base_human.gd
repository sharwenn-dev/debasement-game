extends CharacterBody3D

@onready var player = get_tree().get_first_node_in_group("Player")
var in_dialogue_range = false
var being_talked_to = false

@export var data = {
	"max_health": 50,
	"health": 50,
	"max_hunger": 100,
	"hunger": 10,
}

@export var dialogue = [
	"debaser",
	"thats what they called me in high school",
	"NO DIALOGUE"
]

func _physics_process(delta: float) -> void:
	if player.current_dialogue_set == dialogue:
		being_talked_to = true
	#if player.in_dialogue and not in_dialogue_range and being_talked_to:
		#player.end_dialogue() # FIX HERE!!!!

func interact():
	#data.hunger = clamp(data.hunger + 30, 0, data.max_hunger)
	#queue_free()
	player.do_dialogue(dialogue, 0)


func _on_dialogue_range_body_entered(body: Node3D) -> void:
	if body == player:
		in_dialogue_range = true


func _on_dialogue_range_body_exited(body: Node3D) -> void:
	if body == player:
		in_dialogue_range = false
