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
			print("successfully parsed level data")
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
		push_error("Failed to validate level data")
	var field_data = level_data["field"]
	game_field.LoadData(field_data)
	field_data_extracted.emit(field_data)
	var enemy_data = level_data["enemies"]
	var wave_data = enemy_data["waves"]
	wave_data_extracted.emit(wave_data)


func GenerateUnitLoadout(units):
	var units_data = []
	for unit_id in units:
		units_data.append(GlobalUnitDatabase.units[unit_id])
	generate_unit_loadout.emit(units_data)


func ValidateLevelData(level_data):
	return true


func _ready() -> void:
	UnpackLevel(GlobalLevelData.path)
	GenerateUnitLoadout(["Kitten", "Vygu Vygu", "base_unit"])


func _on_save_level_button_pressed() -> void:
	PackLevel("saved.json")
