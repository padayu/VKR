extends Enemy


@onready var sprite = $Sprite
@onready var sound = $Sound
@onready var attack_timer = $AttackTimer
@onready var unit_detection_area = $UnitDetectionArea


const BASE_SPEED = 25
const BASE_MAX_HEALTH = 240
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
		state.RAGING_DEFAULT:
			move_left_raging(delta)


func change_state(new_state: state):
	super.change_state(new_state)
	match new_state:
		state.ATTACKING:
			sprite.play("attacking")
			attack_timer.wait_time = 0.2
			attack_timer.start()
		state.DEFAULT:
			sprite.play("default")
			attack_timer.stop()
			sound.stop()
		state.RAGING_DEFAULT:
			sprite.play("raging_default")
			attack_timer.stop()
			sound.stop()
		state.RAGING_ATTACKING:
			sprite.play("raging_attacking")
			attack_timer.wait_time = 0.1
			attack_timer.start()


func move_left(delta: float):
	position += BASE_DIRECTION * BASE_SPEED * delta


func move_left_raging(delta: float):
	position += BASE_DIRECTION * BASE_SPEED * delta * 2


func attack():
	if not sound.playing:
		sound.play()
	for unit_in_range in unit_detection_area.get_overlapping_areas():
		unit_in_range.take_melee_hit(1)


func _on_attack_timer_timeout() -> void:
	if current_state == state.ATTACKING:
		attack()
	elif current_state == state.RAGING_ATTACKING:
		attack()


func _on_unit_detection_area_area_entered(_area: Area2D) -> void:
	detected_units += 1
	if detected_units == 1:
		match current_state:
			state.DEFAULT:
				change_state(state.ATTACKING)
			state.RAGING_DEFAULT:
				change_state(state.RAGING_ATTACKING)
			_:
				pass


func _on_unit_detection_area_area_exited(_area: Area2D) -> void:
	detected_units -= 1
	if detected_units == 0:
		match current_state:
			state.ATTACKING:
				change_state(state.DEFAULT)
			state.RAGING_ATTACKING:
				change_state(state.RAGING_DEFAULT)
			_:
				pass


func take_damage(damage):
	super.take_damage(damage)
	if (health <= max_health / 2.0
	and current_state != state.RAGING_DEFAULT 
	and current_state != state.RAGING_ATTACKING):
		if current_state == state.DEFAULT:
			change_state(state.RAGING_DEFAULT)
		elif current_state == state.ATTACKING:
			change_state(state.RAGING_ATTACKING)
