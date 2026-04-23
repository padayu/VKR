extends Label


func _on_resource_manager_mana_value_changed(mana) -> void:
	text = str(mana)
