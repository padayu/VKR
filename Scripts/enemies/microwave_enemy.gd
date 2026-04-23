extends Enemy


@onready var explosion_area = $ExplosionArea



const BASE_SPEED = 20
const BASE_MAX_HEALTH = 80
const BASE_DIRECTION = Vector2(-1, 0)


var detected_units = 0


func _ready() -> void:
	super._ready()
	max_health = BASE_MAX_HEALTH
	health = max_health


func _process(delta: float) -> void:
	match current_state:
		state.DEFAULT:
			move_left(delta)


func change_state(new_state: state):
	super.change_state(new_state)
	match new_state:
		state.ATTACKING:
			attack()
		state.DEFAULT:
			pass


func move_left(delta: float):
	position += BASE_DIRECTION * BASE_SPEED * delta


func attack():
	die()


func _on_attack_timer_timeout() -> void:
	if current_state == state.ATTACKING:
		attack()


func _on_unit_detection_area_area_entered(area: Area2D) -> void:
	detected_units += 1
	if detected_units == 1:
		change_state(state.ATTACKING)


func _on_unit_detection_area_area_exited(area: Area2D) -> void:
	detected_units -= 1
	if detected_units == 0:
		change_state(state.DEFAULT)


func die():
	for unit_in_range in explosion_area.get_overlapping_areas():
		unit_in_range.take_melee_hit(100)
	super.die()
