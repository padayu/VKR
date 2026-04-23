extends Unit


@onready var attack_timer = $AttackTimer
@onready var enemy_detection_area = $EnemyDetectionArea


const BASE_MAX_HEALTH = 40
const BASE_DAMAGE = 10
const BASE_KNOCKBACK = 70


var detected_enemies = 0


func _init() -> void:
	unit_type = "Boxer"


func _ready() -> void:
	super._ready()
	process_state = {}
	max_health = BASE_MAX_HEALTH
	health = max_health
	attack_timer.timeout.connect(_on_attack_timer_timeout)


func change_state(new_state: state):
	super.change_state(new_state)
	match new_state:
		state.ATTACKING:
			attack()
			attack_timer.start()
		state.DEFAULT:
			attack_timer.stop()


func attack():
	for enemy in enemy_detection_area.get_overlapping_areas():
		enemy.take_melee_hit(BASE_DAMAGE)
		enemy.take_knockback(BASE_KNOCKBACK)


func _on_attack_timer_timeout():
	if current_state == state.ATTACKING:
		attack()


func _on_enemy_detection_area_area_entered(area: Area2D) -> void:
	detected_enemies += 1
	if detected_enemies == 1:
		change_state(state.ATTACKING)


func _on_enemy_detection_area_area_exited(area: Area2D) -> void:
	detected_enemies -= 1
	if detected_enemies == 0:
		change_state(state.DEFAULT)


func _on_detectable_area_hit_by_projectile(damage) -> void:
	take_projectile_damage(damage)


func _on_detectable_area_taken_melee_hit(damage) -> void:
	take_melee_damage(damage)
