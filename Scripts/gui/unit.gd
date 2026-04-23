extends Node2D
class_name Unit


signal unit_state_changed
signal health_changed
signal died
signal promoted


enum state {DEFAULT, ATTACKING}


@onready var damage_number_scene = preload("res://Scenes/damage_number.tscn")
@onready var detectable_area = $DetectableArea


var unit_type = "base_unit"


var current_state: state
var process_state: Dictionary
var max_health: int
var health: int
var occupied_tile: Tile


func _ready() -> void:
	current_state = state.DEFAULT
	health_changed.connect(_on_health_changed)
	detectable_area.taken_melee_hit.connect(_on_detectable_area_taken_melee_hit)
	detectable_area.hit_by_projectile.connect(_on_detectable_area_hit_by_projectile)


func _process(delta: float) -> void:
	if current_state in process_state:
		process_state[current_state].call(delta)


func change_state(new_state: state):
	if current_state != new_state:
		current_state = new_state
		unit_state_changed.emit(new_state)


func set_occupied_tile(tile):
	occupied_tile = tile


func get_data():
	return {
		"type": unit_type,
		"grid_x": occupied_tile.grid_x,
		"grid_y": occupied_tile.grid_y
	}


func take_damage(damage):
	health = clamp(health - damage, 0, max_health)
	health_changed.emit()
	var new_damage_number : Node2D = damage_number_scene.instantiate()
	new_damage_number.set_value(damage)
	new_damage_number.set_color(Color("ff0000"))
	add_child(new_damage_number)
	new_damage_number.position = Vector2(randi_range(-40, 40), randi_range(-40, 40))


func take_projectile_damage(damage):
	take_damage(damage)


func take_melee_damage(damage):
	take_damage(damage)


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


func promote(new_type):
	var cost = GlobalUnitDatabase.units[new_type]["cost"]
	GlobalEventBus.spend_mana.emit(cost)
	promoted.emit(new_type)
