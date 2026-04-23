extends Node2D


@onready var file_dialog_open = $FileDialogOpen
@onready var file_dialog_create = $FileDialogCreate


func _on_create_new_pressed() -> void:
	GlobalLevelData.editor_mode = true
	file_dialog_create.open_file_picker()


func _on_choose_file_pressed() -> void:
	GlobalLevelData.editor_mode = true
	file_dialog_open.open_file_picker()


func _on_file_dialog_open_file_selected(path: String) -> void:
	GlobalLevelData.path = path
	get_tree().change_scene_to_file("res://Scenes/level.tscn")


func _on_file_dialog_create_file_selected(path: String) -> void:
	var file = FileAccess.open(path, FileAccess.WRITE)
	var json_string = JSON.stringify({
		"field": {
			"tiles": [
				["lawn", "lawn", "lawn", "lawn", "lawn", "lawn", "lawn"],
				["lawn", "lawn", "lawn", "lawn", "lawn", "lawn", "lawn"],
				["lawn", "lawn", "lawn", "lawn", "lawn", "lawn", "lawn"],
				["lawn", "lawn", "lawn", "lawn", "lawn", "lawn", "lawn"],
				["lawn", "lawn", "lawn", "lawn", "lawn", "lawn", "lawn"]
			],
			"x": 7,
			"y": 5,
			"gap": 0,
			"units": []
		},
		"enemies": {
			"waves": {
				"timed_waves": [
					{
						"timer": 10,
						"enemies": {
							"roomba": 3
						}
					}
				]
			}
		}
	})
	file.store_string(json_string)
	file.close()
	
	GlobalLevelData.path = path
	get_tree().change_scene_to_file("res://Scenes/level.tscn")
