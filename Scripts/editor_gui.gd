extends CanvasLayer


var selected_tile_type = null


signal on_editor_tile_type_changed


func _on_lawn_pressed() -> void:
	on_editor_tile_type_changed.emit("lawn")


func _on_stone_pressed() -> void:
	on_editor_tile_type_changed.emit("stone")


func _on_cancel_pressed() -> void:
	on_editor_tile_type_changed.emit(null)
