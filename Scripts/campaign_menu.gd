extends Node2D


func _on_quit_button_pressed() -> void:
	go_back_to_main_menu()


func go_back_to_main_menu():
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")


func _on_level_1_pressed() -> void:
	GlobalLevelData.editor_mode = false
	GlobalLevelData.path = "res://Data/Levels/level1.json"
	get_tree().change_scene_to_file("res://Scenes/level.tscn")


func _on_level_2_pressed() -> void:
	GlobalLevelData.editor_mode = false
	GlobalLevelData.path = "res://Data/Levels/level2.json"
	get_tree().change_scene_to_file("res://Scenes/level.tscn")
