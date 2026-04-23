extends Button


@export var unit_type = ''
@export var upgrade_cost = 0


signal upgrade_into_new_type


func _ready() -> void:
	pressed.connect(_on_pressed)
	GlobalEventBus.mana_value_changed.connect(_on_mana_value_changed)


func _on_pressed():
	upgrade_into_new_type.emit(unit_type)


func _on_mana_value_changed(value):
	if value >= upgrade_cost:
		disabled = false
	else:
		disabled = true
