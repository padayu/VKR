extends Label




func _on_damage_number_set_label_text(new_text) -> void:
	text = new_text


func _on_damage_number_set_label_color(color) -> void:
	add_theme_color_override("font_color", color)
	add_theme_constant_override("outline_size", 5)
