extends Node2D
class_name Unit


signal unit_state_changed


enum state {DEFAULT, ATTACKING}


var unit_type = "base_unit"


var current_state: state
var process_state: Dictionary
var max_health: int
var health: int
var occupied_tile: Tile


func _ready() -> void:
	current_state = state.DEFAULT


func _process(delta: float) -> void:
	if current_state in process_state:
		process_state[current_state].call(delta)


func change_state(new_state: state):
	if current_state != new_state:
		current_state = new_state
		unit_state_changed.emit(new_state)


func set_occupied_tile(tile):
	occupied_tile = tile


func get_data():
	return {
		"type": unit_type,
		"grid_x": occupied_tile.grid_x,
		"grid_y": occupied_tile.grid_y
	}
