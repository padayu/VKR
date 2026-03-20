extends Node


const DEFAULT_MANA_PRODUCTION_RATE = 5


signal mana_value_changed


var mana = 0:
	set(value):
		mana = value
		mana_value_changed.emit(value)

@onready var timer = $Timer


func _ready():
	timer.wait_time = 1.0 / DEFAULT_MANA_PRODUCTION_RATE
	timer.start()

func _on_timer_timeout():
	mana += 1


func _on_game_field_mana_payment_needed(cost) -> void:
	if mana >= cost:
		mana -= cost
	else:
		print("ATTEMPTED TO PAY MORE MANA THAN CURRENTLY AVAILABLE")
