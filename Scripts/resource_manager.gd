extends Node


const DEFAULT_MANA_PRODUCTION_RATE = 5


signal mana_value_changed


var mana = 0:
	set(value):
		mana = value
		mana_value_changed.emit(value)
		GlobalEventBus.mana_value_changed.emit(value)

@onready var timer = $Timer


func _ready():
	GlobalEventBus.mana_generated.connect(_on_mana_generated)
	GlobalEventBus.spend_mana.connect(_on_spend_mana)
	timer.wait_time = 1.0 / DEFAULT_MANA_PRODUCTION_RATE
	timer.start()


func _on_timer_timeout():
	mana += 1


func _on_game_field_mana_payment_needed(cost) -> void:
	spend_mana(cost)


func _on_mana_generated(amount):
	mana += amount


func _on_spend_mana(amount):
	spend_mana(amount)


func spend_mana(cost):
	if mana >= cost:
		mana -= cost
	else:
		print("ATTEMPTED TO PAY MORE MANA THAN CURRENTLY AVAILABLE")
