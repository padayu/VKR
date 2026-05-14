extends Node2D


func _on_game_field_tile_added(tile) -> void:
	add_child(tile)
