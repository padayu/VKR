extends Node2D


@onready var hitbox = $Hitbox


const BASE_DAMAGE = 5
const BASE_SPEED = 200
const BASE_DIRECTION = Vector2(1, 0)
const MAX_LIFETIME = 20


var current_direction = BASE_DIRECTION
var lifetime = 0


func _process(delta: float) -> void:
	lifetime += delta
	if lifetime > MAX_LIFETIME:
		queue_free()
	position += current_direction * BASE_SPEED * delta


func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.has_method("collide_with_projectile"):
		area.collide_with_projectile(BASE_DAMAGE)
		bounce()


func bounce():
	if -0.001 < current_direction.y and current_direction.y < 0.001:
		var tmp = randi_range(0, 1)
		var new_y
		if tmp == 0:
			new_y = -1
		else:
			new_y = 1
		current_direction.y = new_y
	else:
		current_direction.y = -current_direction.y
