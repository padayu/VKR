extends Unit


@onready var attack_timer = $AttackTimer
@onready var shuriken = $Shuriken
@onready var projectile_scene = preload("res://Scenes/shuriken_projectile.tscn")


const BASE_MAX_HEALTH = 40


var detected_enemies = 0


func _init() -> void:
	unit_type = "NinjaKitten"


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
	var projectile = projectile_scene.instantiate()
	get_parent().get_parent().AddProjectile(projectile)
	shuriken.stop()
	shuriken.play("reloading")
	projectile.position = position + Vector2(8, 24)


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
