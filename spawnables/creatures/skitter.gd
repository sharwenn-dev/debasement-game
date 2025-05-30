extends CharacterBody3D

@onready var nav = $NavigationAgent3D
@onready var detection_range = $detection_range
@onready var player = get_tree().get_first_node_in_group("Player")

const GRAVITY_MULT = 8.0
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * GRAVITY_MULT

var SPEED = 3.0
var ACCEL = 1.0
var RUNSPEED = SPEED * 2.5
var WALKSPEED = SPEED * 0.15

var target = null
var threats_in_range: Array = []

var can_be_hit = true

var detected_threat = false
var player_dialogue_triggered = false

enum WanderState { IDLE, MOVING }
var wander_state = WanderState.IDLE
var wander_timer = 0.0
var idle_duration = 2.0   # shorter idle, skittish
var move_duration = 1.5   # shorter moves, quick hops

# --- New fleeing hesitation variables ---
var fleeing_hesitating = false
var hesitation_time = 0.0
var hesitation_duration = 1.0  # seconds to hesitate (full stop)

@export var data = {
	"max_health": 20,
	"health": 20,
	"max_hunger": 100,
	"hunger": 10,
}

var infinite_range = true
@export var player_spotted_dialogue = [
	"kkkkhh",
	"runrunrun",
	"i saw it again",
	"not safe not safe",
	"chirrp",
	"just shadows",
	"wasn't me",
	"stay gone stay gone",
	"leave",
	"nono no no",
	"...",
	"grkkk",
	"hide. hide. hide.",
	"don't eat me"
]

func _ready():
	nav.target_position = global_position
	detection_range.body_entered.connect(_on_detection_body_entered)
	detection_range.body_exited.connect(_on_detection_body_exited)
	set_wander_idle()

func _on_detection_body_entered(body):
	if body.is_in_group("Human") or body.is_in_group("Player"):
		if not threats_in_range.has(body):
			threats_in_range.append(body)

func _on_detection_body_exited(body):
	if threats_in_range.has(body):
		threats_in_range.erase(body)

func get_nearest_threat():
	if threats_in_range.is_empty():
		return null
	var closest = threats_in_range[0]
	var min_dist = global_position.distance_to(closest.global_position)
	for t in threats_in_range:
		var dist = global_position.distance_to(t.global_position)
		if dist < min_dist:
			closest = t
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

	# Detect threats
	if not detected_threat:
		target = get_nearest_threat()
		if target:
			detected_threat = true
			if target.is_in_group("Player") and not player_dialogue_triggered:
				player_dialogue_triggered = true
				_emit_player_detected_dialogue()
	else:
		# If threat lost or invalid, stop fleeing and resume wandering
		if target == null or not is_instance_valid(target) or not threats_in_range.has(target):
			target = null
			detected_threat = false
			fleeing_hesitating = false  # reset hesitation

	# Movement and behavior
	if target:
		# Flee behavior - run away from threat with hesitation sometimes
		if fleeing_hesitating:
			# During hesitation, do not accelerate; just slowly slow down
			hesitation_time -= delta
			if hesitation_time <= 0.0:
				fleeing_hesitating = false  # end hesitation, resume running

			# Continue current velocity without adding acceleration
			# Slow down velocity gradually by lerping towards zero velocity on horizontal plane
			var vel_horizontal = Vector3(velocity.x, 0, velocity.z)
			vel_horizontal = vel_horizontal.lerp(Vector3.ZERO, 2.5 * delta)
			velocity.x = vel_horizontal.x
			velocity.z = vel_horizontal.z

			# Gravity as usual
			if not is_on_floor():
				velocity.y -= gravity * delta
			else:
				velocity.y = 0

			move_and_slide()
			return  # early return to avoid extra movement logic this frame

		else:
			# Chance to enter hesitation state while fleeing (e.g. 1.5% per frame)
			if randf() < 0.015:
				fleeing_hesitating = true
				hesitation_time = hesitation_duration
			else:
				# Normal fleeing run speed
				SPEED = RUNSPEED

			# Set flee target to run away from threat
			var flee_dir = (global_position - target.global_position).normalized()
			var flee_target_pos = global_position + flee_dir * 10.0
			nav.target_position = flee_target_pos

	else:
		# Wander normally with hesitation
		handle_wandering(delta)

	# Rotate toward next nav point
	var dir = nav.get_next_path_position() - global_position
	dir.y = 0
	if dir.length() > 0.01:
		var rot_angle = atan2(dir.x, dir.z)
		rotation.y = lerp_angle(rotation.y, rot_angle, 6 * delta)

	# Velocity update
	var move_dir = dir.normalized()
	velocity = velocity.lerp(move_dir * SPEED, ACCEL * delta)

	# Gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0

	move_and_slide()

func handle_wandering(delta: float):
	wander_timer -= delta
	if wander_state == WanderState.IDLE:
		SPEED = 0.0
		rotation.y += delta * 0.2  # slow spin
		if wander_timer <= 0:
			set_wander_move()
	elif wander_state == WanderState.MOVING:
		# Hesitation: small chance to stop briefly while wandering
		if randf() < 0.01:
			SPEED = 0.0
		else:
			SPEED = WALKSPEED

		if wander_timer <= 0 or nav.distance_to_target() <= 0.5:
			set_wander_idle()

func set_wander_idle():
	wander_state = WanderState.IDLE
	wander_timer = idle_duration + randf_range(0.5, 1.5)
	nav.target_position = global_position

func set_wander_move():
	wander_state = WanderState.MOVING
	wander_timer = move_duration + randf_range(0.5, 1.0)
	var random_offset = Vector3(
		randf_range(-5.0, 5.0),  # smaller wander radius for skittish creature
		0,
		randf_range(-5.0, 5.0)
	)
	var new_target = global_position + random_offset
	nav.target_position = new_target

func _emit_player_detected_dialogue():
	if not player.in_dialogue:
		var valid_lines = player_spotted_dialogue.filter(func(line): return line != "NO DIALOGUE")
		if valid_lines.size() == 0:
			return
		var random_line = valid_lines[randi() % valid_lines.size()]
		var dialogue_sequence = [random_line, "NO DIALOGUE"]
		player.do_dialogue(dialogue_sequence, 0, self)
		print("skitter detected player: %s" % random_line)
