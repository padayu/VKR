extends Control


signal set_timer_value
signal set_number_of_enemies_value


@onready var timer_spin_box = $HBoxContainer/TimerSpinBox
@onready var number_of_enemies_spin_box = $HBoxContainer/NumberOfEnemiesSpinBox


func UpdateData(data):
	set_number_of_enemies_value.emit(data["enemies"]["roomba"])
	set_timer_value.emit(data["timer"])


func ExtractData():
	var data = {
		"enemies": {
			"roomba": number_of_enemies_spin_box.value
		},
		"timer": timer_spin_box.value
	}
	return data


func GetTimer():
	return timer_spin_box.value


func _on_delete_button_pressed() -> void:
	queue_free()
