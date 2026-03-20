extends Node2D


signal timed_wave_added


@onready var waves_vbox = $CanvasLayer/VBoxContainer/VBoxContainer/Waves
@onready var file_dialog_open = $FileDialogOpen
@onready var file_dialog_save = $FileDialogSave
@onready var width_spin_box = $CanvasLayer/VBoxContainer/VBoxContainer/HBoxContainer/WidthSpinBox
@onready var height_spin_box = $CanvasLayer/VBoxContainer/VBoxContainer/HBoxContainer/HeightSpinBox
@onready var wave_info_scene = preload("res://Scenes/wave_info.tscn")

var field = {
	"x": 0,
	"y": 0,
	"tiles": []
}

var timed_waves = []


func _on_add_wave_pressed() -> void:
	var new_wave = {"roomba": 1}
	timed_waves.append(new_wave)
	timed_wave_added.emit(new_wave)


func _on_load_from_file_pressed() -> void:
	file_dialog_open.open_file_picker()


func _on_file_dialog_file_selected(path: String) -> void:
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		file.close()
		var result = JSON.parse_string(content)
		if result == null:
			push_error("Failed to parse JSON")
		else:
			print("successfully parsed level data")
			field = result["field"]
			timed_waves = result["enemies"]["waves"]["timed_waves"]
	update_displayed_data()


func update_displayed_data():
	update_displayed_field_size()
	update_displayed_timed_waves()


func update_displayed_field_size():
	width_spin_box.value = field["x"]
	height_spin_box.value = field["y"]


func update_displayed_timed_waves():
	for wave in timed_waves:
		var new_wave_info = wave_info_scene.instantiate()
		new_wave_info.update_data(wave)
		waves_vbox.add_child(new_wave_info)


func _on_export_pressed() -> void:
	file_dialog_save.open_file_picker()


func _on_file_dialog_save_file_selected(path: String) -> void:
	var file = FileAccess.open(path, FileAccess.WRITE)
	var json_string = JSON.stringify({
		"field": field,
		"enemies": {
			"waves": {
				"timed_waves": timed_waves
			}
		}
		})
	file.store_string(json_string)
	file.close()


func _on_width_spin_box_value_changed(value: float) -> void:
	field["x"] = int(value)
	regenerate_field()


func _on_height_spin_box_value_changed(value: float) -> void:
	field["y"] = int(value)
	regenerate_field()


func regenerate_field():
	var new_tiles = []
	for row in range(field["y"]):
		new_tiles.append([])
		for col in range(field["x"]):
			new_tiles[row].append("lawn")
	field["tiles"] = new_tiles


func _on_back_to_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
