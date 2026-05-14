extends Control


signal generated_unit_cards
signal selected_unit_card


var unit_card_scene = preload("res://Scenes/unit_card.tscn")

var unit_cards: Array[Button] = []


func _ready() -> void:
	GlobalEventBus.mana_value_changed.connect(_on_mana_value_changed)


func _on_level_loader_generate_unit_loadout(units_data) -> void:
	for unit in units_data:
		var card = generate_unit_card(unit)
		card.set_unit_data(unit)
		unit_cards.append(card)
		card.unit_card_toggled.connect(_on_unit_card_toggled)
	generated_unit_cards.emit(unit_cards)


func generate_unit_card(data):
	var new_card = unit_card_scene.instantiate()
	new_card.set_unit_data(data)
	return new_card


func _on_unit_card_toggled(toggled_on, toggled_card):
	if toggled_on:
		for unit_card in unit_cards:
			if unit_card != toggled_card:
				unit_card.set_pressed_no_signal(false)
		selected_unit_card.emit(toggled_card)
	else:
		selected_unit_card.emit(null)


func _on_mana_value_changed(mana) -> void:
	for unit_card in unit_cards:
		unit_card.update_availability(mana)
