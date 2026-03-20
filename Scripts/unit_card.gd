extends Button


signal unit_card_toggled
signal set_preview_image
signal set_unit_name
signal set_unit_cost


var unit


func update_availability(mana):
	if mana >= unit["cost"]:
		disabled = false
	else:
		disabled = true


func set_unit_data(unit_data):
	unit = unit_data
	set_preview_image.emit(load(unit_data["preview_image"]))
	set_unit_name.emit(unit_data["name"])
	set_unit_cost.emit(unit_data["cost"])


func _on_toggled(toggled_on: bool) -> void:
	unit_card_toggled.emit(toggled_on, self)
