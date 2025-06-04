extends BaseItem

@onready var hitbox = preload("res://hit_box.tscn")
@onready var attack_sound = preload("res://assets/sound/sfx/pipe_swing.wav")

@export var item_name = "Metal Pipe"
@export var cooldown_time = 0.75
@export var max_durability = 10

var durability = max_durability
var can_be_used = true

@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	check_origin()
	if durability <= 0:
		player.aud3.pitch_scale = 1.0
		queue_free()

func activate():
	if not can_be_used or durability <= 0:
		return
	can_be_used = false
	
	var hitbox_instance = hitbox.instantiate()
	player.hitbox_pos.add_child(hitbox_instance)
	hitbox_instance.damage = 10
	hitbox_instance.global_position = player.hitbox_pos.global_position

	var pitch_scale = lerp(0.5, 1.0, float(durability) / max_durability)
	player.aud3.pitch_scale = pitch_scale
	player.play_sound(attack_sound, player.aud3)
	
	var cam = player.camera
	var original_fov = cam.fov
	var punch_fov = original_fov + 5.0 
	cam.fov = punch_fov
	var original_pos = cam.position
	var elapsed = 0.0
	var shake_duration = 0.15
	
	while elapsed < shake_duration:
		var shake_offset := Vector3(
			randf_range(-0.04, 0.04),
			randf_range(-0.04, 0.04),
			randf_range(-0.04, 0.04)
		)
		cam.position = original_pos + shake_offset
		await get_tree().process_frame
		elapsed += get_process_delta_time()
	
	cam.position = original_pos
	await get_tree().create_timer(0.1).timeout
	cam.fov = original_fov
	await get_tree().create_timer(0.1).timeout
	hitbox_instance.queue_free()
	
	durability -= 1
	await get_tree().create_timer(cooldown_time).timeout
	can_be_used = true
