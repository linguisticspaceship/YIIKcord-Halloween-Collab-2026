extends Area3D

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		#position.x = event.relative.x
		$CollisionShape3D.rotate_y(-event.relative.x * 0.01)
		#position.y = event.relative.y
