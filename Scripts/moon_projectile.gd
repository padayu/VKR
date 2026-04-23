extends Node2D


@onready var hitbox = $Hitbox


const BASE_DAMAGE = 24


func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.has_method("collide_with_projectile"):
		area.collide_with_projectile(BASE_DAMAGE)
