extends Area3D

var damage = 0

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Hittable"):
		body.take_damage(damage)
