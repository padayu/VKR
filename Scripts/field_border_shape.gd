extends CollisionShape2D


func _on_game_field_move_and_resize_field_border(new_a, new_b) -> void:
	shape.a = new_a
	shape.b = new_b
