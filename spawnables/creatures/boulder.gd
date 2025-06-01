extends CharacterBody3D

@onready var atk_area = $attack_area
@onready var nav = $NavigationAgent3D
@onready var attack_range = $attack_range
@onready var aura_range = $aura_range
@onready var player = get_tree().get_first_node_in_group("Player")

const GRAVITY_MULT = 8.0
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * GRAVITY_MULT

var SPEED = 3.0
var ACCEL = 0.5
var ATTACK = 25
var KNOCKBACK = 45.0
var RUNSPEED = SPEED * 1.5
var WALKSPEED = SPEED * 0.15

var target = null
var humans_in_range: Array = []

var can_be_hit = true
var attack_cooldown = 0.5
var attack_timer = 0.0

var detected_human = false
var player_dialogue_triggered = false

enum WanderState { IDLE, MOVING }
var wander_state = WanderState.IDLE
var wander_timer = 0.0
var idle_duration = 5.5
var move_duration = 3.5

@export var data = {
	"max_health": 500,
	"health": 500,
	"max_hunger": 100,
	"hunger": 100,
}

var infinite_range = true
@export var player_spotted_dialogue = [
	"I AM THE END.",
	"YOU CANNOT ESCAPE.",
	"THE GROUND TREMBLES FOR YOU.",
	"FEEL THE WEIGHT OF FATE.",
	"YOUR PATH IS CRUSHED.",
	"NO SHADOW CAN HIDE YOU.",
	"I MOVE WITHOUT MERCY.",
	"THE EARTH REMEMBERS ME.",
	"I WILL CONSUME ALL.",
	"STAND STILL AND BE BROKEN.",
	"THE VOID OPENS BENEATH.",
	"HARDER THAN STONE.",
	"YOU ARE INSIGNIFICANT.",
	"I AM UNSTOPPABLE.",
	"THE CRUSHING SILENCE COMES.",
	"NOTHING CAN BLOCK ME.",
	"NO DIALOGUE"
]

var time_in_aura = 0.0
const AURA_DURATION_TO_LAUNCH = 2.0
const UPWARD_LAUNCH_VELOCITY = 20.0  # Adjust as needed

func _ready():
	nav.target_position = global_position
	attack_range.body_entered.connect(_on_attack_range_body_entered)
	attack_range.body_exited.connect(_on_attack_range_body_exited)
	set_wander_idle()

func _on_attack_range_body_entered(body):
	if body.is_in_group("Human") and not humans_in_range.has(body):
		humans_in_range.append(body)

func _on_attack_range_body_exited(body):
	if humans_in_range.has(body):
		humans_in_range.erase(body)

func get_nearest_human():
	if humans_in_range.is_empty():
		return null
	var closest = humans_in_range[0]
	var min_dist = global_position.distance_to(closest.global_position)
	for h in humans_in_range:
		var dist = global_position.distance_to(h.global_position)
		if dist < min_dist:
			closest = h
			min_dist = dist
	return closest

func take_damage(damage, type):
	if can_be_hit:
		data.health = clamp(data.health - damage, 0, data.max_health)
		can_be_hit = false
		await get_tree().create_timer(0.12).timeout
		can_be_hit = true

func _physics_process(delta: float) -> void:
	if data.health <= 0:
		queue_free()
		return

	attack_timer = max(attack_timer - delta, 0)

	var dir = Vector3.ZERO  # declare upfront

	# never stop chasing first target
	if not detected_human:
		target = get_nearest_human()
		if target:
			detected_human = true
			if target.is_in_group("Player") and not player_dialogue_triggered:
				player_dialogue_triggered = true
				_emit_player_detected_signal_or_run_dialogue()
	else:
		if target == null or not is_instance_valid(target):
			detected_human = false
			target = get_nearest_human()
			player_dialogue_triggered = false

	if target:
		SPEED = RUNSPEED

		# Set nav target to the exact player position (no random offset)
		nav.target_position = target.global_position

		# Calculate direction vector directly toward the target, ignoring nav path points
		dir = (target.global_position - global_position)
		dir.y = 0

		# If very close, stop moving (to prevent jitter)
		if dir.length() < 0.5:
			dir = Vector3.ZERO

		# Attack logic
		if atk_area.overlaps_body(target) and attack_timer <= 0:
			if target.has_method("take_damage"):
				target.take_damage(ATTACK, "tear")
			if "inertia" in target:
				target.inertia = (target.global_position - global_position).normalized() * KNOCKBACK
			attack_timer = attack_cooldown

		# New: Launch the target upward if in aura_range long enough
		if aura_range.get_overlapping_bodies().has(target):
			time_in_aura += delta
			if time_in_aura >= AURA_DURATION_TO_LAUNCH:
				# Apply upward velocity to the target
				if target.has_method("add_velocity"):
					target.add_velocity(Vector3.UP * UPWARD_LAUNCH_VELOCITY)
				elif "velocity" in target:
					target.velocity.y = UPWARD_LAUNCH_VELOCITY
				time_in_aura = 0.0
		else:
			time_in_aura = 0.0

	else:
		# No target: wander normally
		handle_wandering(delta)

		# Use nav path for wandering movement
		dir = nav.get_next_path_position() - global_position
		dir.y = 0
		if dir.length() < 0.01:
			dir = Vector3.ZERO

	# Rotate smoothly toward movement direction
	if dir.length() > 0:
		var rot_angle = atan2(dir.x, dir.z)
		rotation.y = lerp_angle(rotation.y, rot_angle, 6 * delta)

	# Move velocity smoothly toward target direction
	var move_dir = dir.normalized()
	velocity = velocity.lerp(move_dir * SPEED, ACCEL * delta)

	# Gravity and vertical movement
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0

	move_and_slide()

func handle_wandering(delta: float):
	wander_timer -= delta
	if wander_state == WanderState.IDLE:
		SPEED = 0.0
		rotation.y += delta * 0.2  
		if wander_timer <= 0:
			set_wander_move()
	elif wander_state == WanderState.MOVING:
		SPEED = WALKSPEED
		if wander_timer <= 0 or nav.distance_to_target() <= 0.5:
			set_wander_idle()

func set_wander_idle():
	wander_state = WanderState.IDLE
	wander_timer = idle_duration + randf_range(1.0, 3.0)
	nav.target_position = global_position

func set_wander_move():
	wander_state = WanderState.MOVING
	wander_timer = move_duration + randf_range(1.0, 2.0)
	var random_offset = Vector3(
		randf_range(-30.0, 30.0),
		0,
		randf_range(-30.0, 30.0)
	)
	var new_target = global_position + random_offset
	nav.target_position = new_target

func _emit_player_detected_signal_or_run_dialogue():
	if not player.in_dialogue:
		var valid_lines = player_spotted_dialogue.filter(func(line): return line != "NO DIALOGUE")
		if valid_lines.size() == 0:
			return
		var random_line = valid_lines[randi() % valid_lines.size()]
		var dialogue_sequence = [random_line, "NO DIALOGUE"]
		player.do_dialogue(dialogue_sequence, 0, self)
		print("boulder detected player: %s" % random_line)
