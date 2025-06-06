extends BaseValue

func _ready() -> void:
	initialized = false

func value_effects():
	player.drop_item(player.data.left)
	player.drop_item(player.data.right)
	player.can_talk = false

func initialize():
	if not initialized:
		player.data.can_get_value = false
		value_effects()
		player.value_box.text = value_name
		player.value_box.visible = true
		await get_tree().create_timer(5).timeout
		player.value_box.visible = false
		player.value_box.text = ""
		player.data.can_get_value = true
		initialized = true
		queue_free()
