extends CharacterBody3D

@onready var player = get_tree().get_first_node_in_group("Player")
@onready var dialogue_range = $dialogue_range
@onready var aud = $AudioStreamPlayer3D
@onready var damage_sound = preload("res://assets/sound/sfx/creature_hurt.wav")

var in_dialogue_range = false
var infinite_range = false
var can_be_hit = true

@export var interact_type = "Talk"

@export var data = {
	"max_health": 50,
	"health": 50,
	"max_hunger": 100,
	"hunger": 10,
	"can_talk": true,
	"talked_to": false,
	"dialogue_set": dialogue,
}

@export var dialogue = ["NO DIALOGUE"]
@export var killing_dialogue = ["NO DIALOGUE"]

@export var rotation_speed: float = 5.0

func _ready() -> void:
	rotation.y = randf_range(0.0, TAU)

	if dialogue.size() == 1 and dialogue[0] == "NO DIALOGUE":
		dialogue = generate_random_dialogue()
	if killing_dialogue.size() == 1 and killing_dialogue[0] == "NO DIALOGUE":
		killing_dialogue = generate_random_dialogue(true)

func take_damage(damage, type):
	if can_be_hit:
		aud.stream = damage_sound
		aud.play()
		data.health = clamp(data.health - damage, 0, data.max_health)
		can_be_hit = false
		player.end_dialogue()
		data.can_talk = false
		await get_tree().create_timer(0.2).timeout
		can_be_hit = true

func _physics_process(delta: float) -> void:
	dialogue_range.monitoring = true

	if data.health <= 0:
		player.data.value.killing += 1
		queue_free()

	if (player.in_dialogue and in_dialogue_range) or in_dialogue_range:
		var to_player = player.global_transform.origin - global_transform.origin
		to_player.y = 0
		if to_player.length() > 0.01:
			var target_rotation = atan2(to_player.x, to_player.z)
			rotation.y = lerp_angle(rotation.y, target_rotation, rotation_speed * delta)

func interact():
	if data.can_talk and player.can_talk:
		in_dialogue_range = true
		dialogue_range.monitoring = true
		player.do_dialogue(dialogue, 0, self)
		data.talked_to = true

func _on_dialogue_range_body_entered(body: Node3D) -> void:
	if body == player:
		in_dialogue_range = true

func _on_dialogue_range_body_exited(body: Node3D) -> void:
	if body == player:
		in_dialogue_range = false
		player.end_dialogue()

func generate_random_dialogue(is_hostile := false) -> Array:
	var subjects = ["i", "we", "this one", "pipe-thing", "meat unit", "god", "voidchild", "skin"]
	var verbs = ["know", "forgot", "ate", "became", "feel", "is", "rot", "speak", "listen"]
	var objects = ["nothing", "a shape", "your value", "the mud", "heat death", "wet wires", "the reason", "the rules"]
	var suffixes = ["again", "maybe", "forever", "wrong", "from above", "inside out", "before sleep", "by accident"]

	var lines = []

	for i in range(randi() % 3 + 2): 
		var s = subjects.pick_random()
		var v = verbs.pick_random()
		var o = objects.pick_random()
		var x = suffixes.pick_random()
		var line = "%s %s %s %s" % [s, v, o, x]
		lines.append(line.capitalize())

	if is_hostile:
		lines.append("go. leave me boneside.")

	lines.append("NO DIALOGUE")
	return lines
