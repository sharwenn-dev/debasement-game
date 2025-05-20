extends BaseValue

func _ready() -> void:
	initialized = false

func initialize():
	if not initialized:
		player.drop_item(player.data.left)
		player.drop_item(player.data.right)
		player.value_box.text = value_name
		player.value_box.visible = true
		await get_tree().create_timer(5).timeout
		player.value_box.visible = false
		player.value_box.text = ""
		initialized = true
		queue_free()
