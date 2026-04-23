extends Node2D


signal set_label_text
signal set_label_color


@onready var label = $Label


const SPEED = 40
const MAX_LIFETIME = 2


var time_alive = 0


func _process(delta: float) -> void:
	time_alive += delta
	if time_alive > MAX_LIFETIME:
		queue_free()
	position.y -= SPEED * delta


func set_value(damage):
	set_label_text.emit(str(damage))


func set_color(color):
	set_label_color.emit(color)
