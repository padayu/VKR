extends Area2D


signal hit_by_projectile


func collide_with_projectile(damage):
	hit_by_projectile.emit(damage)
