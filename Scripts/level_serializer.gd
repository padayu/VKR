extends Node
class_name LevelLoader

signal generate_unit_loadout
signal field_data_extracted
signal wave_data_extracted


@onready var level = self.get_parent()
@onready var game_field = level.find_child("GameField")
@onready var wave_manager = level.find_child("WaveManager")


func ReadLevelFromFile(filename):
	var file = FileAccess.open(filename, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		file.close()
		var result = JSON.parse_string(content)
		if result == null:
			push_error("Failed to parse JSON")
		else:
			print("Successfully parsed level data")
		return result


func WriteLevelToFile(filename, data):
	var json_string = JSON.stringify(data)
	var file = FileAccess.open(filename, FileAccess.WRITE)
	file.store_string(json_string)
	file.close()


func PackLevel(filename):
	var field_data = game_field.ExtractData()
	var wave_data = wave_manager.ExtractData()
	var data = {
		"field": field_data,
		"enemies": {
			"waves": wave_data
		}
	}
	WriteLevelToFile(filename, data)


func UnpackLevel(filename):
	var level_data = ReadLevelFromFile(filename)
	if not ValidateLevelData(level_data):
		print("Failed to validate level data")
		get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
	else:
		print("Level valid")
	
	var field_data = {
		"gap": 0.0,
		"tiles": [["lawn"]],
		"units": [],
		"x": 1,
		"y": 1
	}
	var enemy_data = {
		"waves": {
			"timed_waves":[]
			}
	}
	if typeof(level_data) == TYPE_DICTIONARY:
		if "field" in level_data:
			field_data = level_data["field"]
		game_field.LoadData(field_data)
		field_data_extracted.emit(field_data)
		if "enemies" in level_data:
			enemy_data = level_data["enemies"]
	
	var wave_data = enemy_data["waves"]
	wave_data_extracted.emit(wave_data)


func GenerateUnitLoadout(units):
	var units_data = []
	for unit_id in units:
		units_data.append(GlobalUnitDatabase.units[unit_id])
	generate_unit_loadout.emit(units_data)


# TODO update validation
func ValidateLevelData(level_data):
	if typeof(level_data) != TYPE_DICTIONARY:
		return false
		
	if "field" not in level_data:
		return false
	var field_data = level_data["field"]
	if typeof(field_data) != TYPE_DICTIONARY:
		return false
	if "x" not in field_data or "y" not in field_data:
		return false
	if typeof(field_data["x"]) != TYPE_FLOAT and typeof(field_data["x"]) != TYPE_INT:
		return false
	if typeof(field_data["y"]) != TYPE_FLOAT and typeof(field_data["y"]) != TYPE_INT:
		return false
	if "tiles" not in field_data or "units" not in field_data:
		return false
		
	var tiles_data = field_data["tiles"]
	if typeof(tiles_data) != TYPE_ARRAY:
		return false
	if len(tiles_data) != field_data["y"]:
		return false
	for row in tiles_data:
		if typeof(row) != TYPE_ARRAY:
			return false
		if len(row) != field_data["x"]:
			return false
		for cell in row:
			if typeof(cell) != TYPE_STRING:
				return false
	
	var units_data = field_data["units"]
	if typeof(units_data) != TYPE_ARRAY:
		return false
	for unit in units_data:
		if typeof(unit) != TYPE_DICTIONARY:
			return false
	
	if "enemies" not in level_data:
		return false
	var enemies_data = level_data["enemies"]
	if typeof(enemies_data) != TYPE_DICTIONARY:
		return false
	
	return true


func _ready() -> void:
	UnpackLevel(GlobalLevelData.path)
	GenerateUnitLoadout(["Kitten", "Mandrake", "Boxer", "Planet"])


func _on_save_level_button_pressed() -> void:
	PackLevel(GlobalLevelData.path)
