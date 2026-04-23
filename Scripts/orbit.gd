extends Node2D


const BASE_ROTATION_SPEED = 1.0


func _process(delta: float) -> void:
	rotation += BASE_ROTATION_SPEED * delta
