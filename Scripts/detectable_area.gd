extends Area2D


signal hit_by_projectile
signal taken_melee_hit
signal taken_knockback


func collide_with_projectile(damage):
	hit_by_projectile.emit(damage)


func take_melee_hit(damage):
	taken_melee_hit.emit(damage)


func take_knockback(amount):
	taken_knockback.emit(amount)
