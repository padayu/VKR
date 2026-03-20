extends Enemy


const BASE_SPEED = 50
const BASE_MAX_HEALTH = 20
const BASE_DIRECTION = Vector2(-1, 0)


func _ready() -> void:
	super._ready()
	max_health = BASE_MAX_HEALTH
	health = max_health


func _process(delta: float) -> void:
	match current_state:
		state.DEFAULT:
			move_left(delta)


func move_left(delta: float):
	position += BASE_DIRECTION * BASE_SPEED * delta


func take_damage(damage):
	health = clamp(health - damage, 0, max_health)
	health_changed.emit()


func die():
	died.emit()
	queue_free()


func _on_detectable_area_hit_by_projectile(damage) -> void:
	take_damage(damage)


func _on_health_changed() -> void:
	if health == 0:
		die()
