extends OptionButton


signal selected_item_chosen


var enemy_names = {}


func _ready() -> void:
	if item_count == 0: 
		UpdateEnemyTypes()


func _on_wave_info_set_enemy_type_value(type_to_set) -> void:
	UpdateEnemyTypes()
	var matching_name = null
	if type_to_set in enemy_names:
		matching_name = enemy_names[type_to_set]
	if matching_name == null:
		return
	var matching_id = -1
	for item_id in range(item_count):
		if get_item_text(item_id) == matching_name:
			matching_id = item_id
			break
	if matching_id != -1:
		select(matching_id)


func UpdateEnemyTypes():
	for enemy_type in GlobalEnemyDatabase.enemies:
		enemy_names[enemy_type] = GlobalEnemyDatabase.enemies[enemy_type]["name"]
		add_item(GlobalEnemyDatabase.enemies[enemy_type]["name"])


func GetEnemyClass():
	for enemy_class in enemy_names:
		if enemy_names[enemy_class] == get_item_text(selected):
			return enemy_class
