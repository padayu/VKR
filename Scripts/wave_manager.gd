extends Node


signal spawn_enemy_in_row
signal no_more_timed_waves


var time_passed = 0
var n_rows: int
var enemy_scenes: Dictionary = {}
var timed_waves = []
var next_timed_wave_id = 0
var finished_time_waves = false
var waves_list = null


func _process(delta: float) -> void:
	time_passed += delta
	manage_timed_waves()


func _on_level_loader_wave_data_extracted(wave_data) -> void:
	var timed_wave_data = wave_data["timed_waves"]
	timed_waves = timed_wave_data
	for wave in timed_waves:
		for enemy in wave["enemies"]:
			enemy_scenes[enemy] = load(GlobalEnemyDatabase.enemies[enemy]["path"])
	recalculate_timed_wave()


func spawn_wave_basic(enemy, number, interval = 0.2):
	var enemy_scene = enemy_scenes[enemy]
	if number <= 0:
		return
	var row = randi_range(0, n_rows - 1)
	spawn_enemy_in_row.emit(enemy_scene, row)
	
	get_tree().create_timer(interval).timeout.connect(
		func(): spawn_wave_basic(enemy, number - 1, interval)
	)


func manage_timed_waves():
	while (
		next_timed_wave_id < len(timed_waves) 
		and time_passed >= timed_waves[next_timed_wave_id]["timer"]
		):
			spawn_next_timed_wave()
			next_timed_wave_id += 1
	if next_timed_wave_id == len(timed_waves):
		if not finished_time_waves:
			finished_time_waves = true
			no_more_timed_waves.emit()
			print("finished spawning stuff")


func recalculate_timed_wave():
	next_timed_wave_id = 0
	while (
		next_timed_wave_id < len(timed_waves) 
		and time_passed >= timed_waves[next_timed_wave_id]["timer"]
		):
			next_timed_wave_id += 1


func spawn_next_timed_wave():
	for enemy in timed_waves[next_timed_wave_id]["enemies"]:
		spawn_wave_basic(enemy, timed_waves[next_timed_wave_id]["enemies"][enemy])


func _on_level_loader_field_data_extracted(field_data) -> void:
	n_rows = field_data["y"]


func ExtractData():
	UpdateTimedWavesFromEditor()
	var data = {
		"timed_waves": timed_waves
	}
	return data


func UpdateTimedWavesFromEditor():
	if waves_list != null:
		timed_waves = waves_list.ExtractData()
		recalculate_timed_wave()


func UpdateTimedWavesFromData(new_timed_waves):
	timed_waves = new_timed_waves
	recalculate_timed_wave()


func _on_waves_list_on_waves_list_ready(waves_list_) -> void:
	waves_list = waves_list_


func _on_save_waves_pressed() -> void:
	UpdateTimedWavesFromEditor()
