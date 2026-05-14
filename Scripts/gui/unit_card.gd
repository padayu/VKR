class_name UnitCard
extends Button


@onready var timer = $Timer
@onready var cooldown_label = $CooldownLabel


signal unit_card_toggled
signal set_preview_image
signal set_unit_name
signal set_unit_cost
signal set_unit_cooldown


var unit
var last_mana_value


func _process(_delta: float) -> void:
	cooldown_label.text = "%.1f" % timer.time_left


func start_cooldown():
	cooldown_label.visible = true
	timer.start()
	disabled = true


func update_availability(mana=last_mana_value):
	if mana >= unit["cost"] and timer.is_stopped():
		disabled = false
	else:
		disabled = true
	last_mana_value = mana


func set_unit_data(unit_data):
	unit = unit_data
	set_preview_image.emit(load(unit_data["preview_image"]))
	set_unit_name.emit(unit_data["name"])
	set_unit_cost.emit(unit_data["cost"])
	set_unit_cooldown.emit(unit_data["cooldown"])


func _on_toggled(toggled_on: bool) -> void:
	unit_card_toggled.emit(toggled_on, self)


func _on_timer_timeout() -> void:
	cooldown_label.visible = false
	update_availability()
