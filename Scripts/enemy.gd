extends Node2D
class_name Enemy


signal state_changed
signal health_changed
signal died


enum state {DEFAULT, ATTACKING}


var current_state: state
var max_health: int
var health: int


func _ready() -> void:
	current_state = state.DEFAULT


func change_state(new_state: state):
	if current_state != new_state:
		current_state = new_state
		state_changed.emit(new_state)
