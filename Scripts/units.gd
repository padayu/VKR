extends Node


func _on_game_field_on_add_unit(unit) -> void:
	add_child(unit)
