extends Node2D
class_name Enemy


signal state_changed
signal health_changed
signal died


@onready var damage_number_scene = preload("res://Scenes/damage_number.tscn")
@onready var detectable_area = $DetectableArea


enum state {
	DEFAULT, 
	ATTACKING, 
	RAGING_DEFAULT,
	RAGING_ATTACKING,
	RECOIL,
	}


var current_state: state
var max_health: int
var health: int


func _ready() -> void:
	current_state = state.DEFAULT
	health_changed.connect(_on_health_changed)
	state_changed.connect(_on_state_changed)
	detectable_area.taken_melee_hit.connect(_on_detectable_area_taken_melee_hit)
	detectable_area.hit_by_projectile.connect(_on_detectable_area_hit_by_projectile)
	detectable_area.taken_knockback.connect(_on_detectable_area_taken_knockback)


func change_state(new_state: state):
	if current_state != new_state:
		current_state = new_state
		state_changed.emit(new_state)


func take_damage(damage):
	health = clamp(health - damage, 0, max_health)
	health_changed.emit()
	var new_damage_number : Node2D = damage_number_scene.instantiate()
	new_damage_number.set_value(damage)
	new_damage_number.set_color(Color("dddd00"))
	add_child(new_damage_number)
	new_damage_number.position = Vector2(randi_range(-40, 40), randi_range(-40, 40))


func take_projectile_damage(damage):
	take_damage(damage)


func take_melee_damage(damage):
	take_damage(damage)


func take_knockback(knockback):
	position.x += knockback


func die():
	died.emit()
	queue_free()


func _on_health_changed() -> void:
	if health == 0:
		die()


func _on_detectable_area_hit_by_projectile(damage) -> void:
	take_projectile_damage(damage)


func _on_detectable_area_taken_melee_hit(damage) -> void:
	take_melee_damage(damage)


func _on_detectable_area_taken_knockback(amount) -> void:
	take_knockback(amount)


func _on_state_changed(new_state):
	pass
