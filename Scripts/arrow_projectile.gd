extends Node2D


@onready var hitbox = $Hitbox


const BASE_DAMAGE = 10
const BASE_SPEED = 250
const BASE_DIRECTION = Vector2(1, 0)
const MAX_LIFETIME = 20


var lifetime = 0


func _process(delta: float) -> void:
	lifetime += delta
	if lifetime > MAX_LIFETIME:
		queue_free()
	position += BASE_DIRECTION * BASE_SPEED * delta


func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.has_method("collide_with_projectile"):
		area.collide_with_projectile(BASE_DAMAGE)
		var tmp = randi_range(0, 2)
		if tmp == 0:
			break_from_impact()


func break_from_impact():
	queue_free()
