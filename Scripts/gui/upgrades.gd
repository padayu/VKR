extends HBoxContainer


func _ready() -> void:
	for child in get_children():
		child.upgrade_into_new_type.connect(_on_child_clicked)


func _on_child_clicked(new_type):
	get_parent().promote(new_type)
