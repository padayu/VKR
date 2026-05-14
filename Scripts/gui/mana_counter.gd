extends Label


func _ready() -> void:
	GlobalEventBus.mana_value_changed.connect(_on_mana_value_changed)

func _on_mana_value_changed(mana) -> void:
	text = str(mana)
