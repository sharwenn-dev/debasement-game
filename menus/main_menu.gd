extends CanvasLayer


func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://test_world_2.tscn")

func _on_start_2_pressed() -> void:
	get_tree().change_scene_to_file("res://test_world.tscn")


func _on_exit_pressed() -> void:
	get_tree().quit()
