extends Enemy


@onready var sprite: AnimatedSprite2D = $Sprite
@onready var recoil_timer = $RecoilTimer


const BASE_SPEED = 80
const BASE_MAX_HEALTH = 20
const BASE_DAMAGE = 7
const BASE_DIRECTION = Vector2(-1, 0)


func _ready() -> void:
	super()
	max_health = BASE_MAX_HEALTH
	health = max_health


func _process(delta: float) -> void:
	match current_state:
		state.DEFAULT:
			move_left(delta)
	match current_state:
		state.RECOIL:
			move_right(delta)


func move_left(delta: float):
	position += BASE_DIRECTION * BASE_SPEED * delta


func move_right(delta: float):
	position -= BASE_DIRECTION * (BASE_SPEED * 0.5) * delta


func _on_unit_detection_area_area_entered(area: Area2D) -> void:
	if current_state == state.DEFAULT:
		area.take_melee_hit(BASE_DAMAGE)
		change_state(state.RECOIL)


func _on_state_changed(new_state):
	if new_state == state.RECOIL:
		sprite.play("recoil")
		recoil_timer.start()
	elif new_state == state.DEFAULT:
		sprite.play("default")


func _on_recoil_timer_timeout() -> void:
	change_state(state.DEFAULT)
