extends Control


signal set_timer_value
signal set_number_of_enemies_value
signal set_enemy_type_value


@onready var timer_spin_box = $HBoxContainer/TimerSpinBox
@onready var number_of_enemies_spin_box = $HBoxContainer/NumberOfEnemiesSpinBox
@onready var enemy_type_dropdown = $HBoxContainer/EnemyTypeDropdown


func UpdateData(data):
	var enemy_type = null
	for new_enemy_type in data["enemies"]:
		enemy_type = new_enemy_type
		break
	set_number_of_enemies_value.emit(data["enemies"][enemy_type])
	set_timer_value.emit(data["timer"])
	set_enemy_type_value.emit(enemy_type)


func ExtractData():
	var data = {
		"enemies": {
			enemy_type_dropdown.GetEnemyClass(): number_of_enemies_spin_box.value
		},
		"timer": timer_spin_box.value
	}
	return data


func GetTimer():
	return timer_spin_box.value


func _on_delete_button_pressed() -> void:
	queue_free()
