extends Node2D


func _on_select_file_pressed():
	$FileDialog.open_file_picker()


func _on_file_dialog_file_selected(path: String) -> void:
	GlobalLevelData.path = path
	get_tree().change_scene_to_file("res://Scenes/level.tscn")


func _on_editor_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/level_editor.tscn")
