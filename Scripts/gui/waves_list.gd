extends VBoxContainer


var wave_info_scene = null


signal on_waves_list_ready


func _ready() -> void:
	on_waves_list_ready.emit(self)


func LoadData(waves_data):
	for wave in waves_data:
		AddWave(wave)


func AddWave(wave_data):
	var new_wave = wave_info_scene.instantiate()
	add_child(new_wave)
	new_wave.UpdateData(wave_data)


func ExtractData():
	var data = []
	var sorted_waves = get_children()
	sorted_waves.sort_custom(func(a, b): return a.GetTimer() < b.GetTimer())
	for wave in sorted_waves:
		data.append(wave.ExtractData())
	return data


func _on_level_serializer_wave_data_extracted(waves_data) -> void:
	if wave_info_scene == null:
		wave_info_scene = load("res://Scenes/wave_info.tscn")
	LoadData(waves_data["timed_waves"])


func _on_add_wave_pressed() -> void:
	AddWave({
		"timer": 10,
		"enemies": {
			"roomba": 1
		}
	})
