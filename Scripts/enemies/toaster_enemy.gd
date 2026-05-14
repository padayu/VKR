extends Enemy


@onready var attack_timer = $AttackTimer
@onready var sprite = $Sprite
@onready var projectile_scene = preload("res://Scenes/garbage_projectile.tscn")


const BASE_SPEED = 30
const BASE_MAX_HEALTH = 40
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
			sprite.play("attacking")
			attack()
			attack_timer.start()
		state.DEFAULT:
			sprite.play("default")
			attack_timer.stop()


func move_left(delta: float):
	position += BASE_DIRECTION * BASE_SPEED * delta


func attack():
	var projectile = projectile_scene.instantiate()
	get_parent().get_parent().AddProjectile(projectile)
	projectile.position = position
	projectile.position.y -= 20


func _on_attack_timer_timeout() -> void:
	if current_state == state.ATTACKING:
		attack()


func _on_unit_detection_area_area_entered(_area: Area2D) -> void:
	detected_units += 1
	if detected_units == 1:
		change_state(state.ATTACKING)


func _on_unit_detection_area_area_exited(_area: Area2D) -> void:
	detected_units -= 1
	if detected_units == 0:
		change_state(state.DEFAULT)
