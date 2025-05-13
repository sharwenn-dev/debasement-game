extends CharacterBody3D

@onready var player = get_tree().get_first_node_in_group("Player")
@onready var dialogue_range = $dialogue_range
var in_dialogue_range = false
var can_be_hit = true

@export var data = {
	"max_health": 50,
	"health": 50,
	"max_hunger": 100,
	"hunger": 10,
	"talked_to": false,
	"dialogue_set": dialogue,
}

@export var dialogue = [
	"debaser",
	"thats what they called me in high school",
	"NO DIALOGUE"
]

@export var dialogue2 = [
	"I SAID THATS WHAT THEY CALLED ME IN HIGH SCHOOL",
	"go away",
	"NO DIALOGUE"
]

func take_damage(damage):
	if can_be_hit:
		data.health = clamp(data.health - damage, 0, data.max_health)
		can_be_hit = false
		var timer = get_tree().create_timer(0.2)
		await timer.timeout
		can_be_hit = true

func _physics_process(delta: float) -> void:
	#if player.in_dialogue and dialogue_range.monitoring and not in_dialogue_range:
		#player.end_dialogue() # FIX HERE!!!!
	if data.health <= 0:
		queue_free()

func interact():
	#data.hunger = clamp(data.hunger + 30, 0, data.max_hunger)
	#queue_free()
	in_dialogue_range = true
	dialogue_range.monitoring = true
	player.do_dialogue(dialogue, 0, self)
	data.talked_to = true
	data.dialogue_set = dialogue2

func _on_dialogue_range_body_entered(body: Node3D) -> void:
	if body == player:
		in_dialogue_range = true


func _on_dialogue_range_body_exited(body: Node3D) -> void:
	if body == player:
		in_dialogue_range = false
		player.end_dialogue()
