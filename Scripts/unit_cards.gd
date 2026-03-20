extends HBoxContainer



func _on_unit_loadout_generated_unit_cards(generated_cards) -> void:
	for card in generated_cards:
		self.add_child(card)
