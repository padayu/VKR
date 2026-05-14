extends HBoxContainer


signal field_size_changed


@onready var x = $X
@onready var y = $Y


var x_value
var y_value


func _ready() -> void:
	x.value = x_value
	y.value = y_value


func _on_level_serializer_field_data_extracted(field_data) -> void:
	x_value = field_data["x"]
	y_value = field_data["y"]


func _on_x_value_changed(value: float) -> void:
	field_size_changed.emit(x.value, y.value)


func _on_y_value_changed(value: float) -> void:
	field_size_changed.emit(x.value, y.value)
