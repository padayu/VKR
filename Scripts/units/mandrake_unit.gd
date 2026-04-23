extends Unit


@onready var production_timer = $ProductionTimer


const BASE_MAX_HEALTH = 20


func _init() -> void:
	unit_type = "Mandrake"


func _ready() -> void:
	super._ready()
	process_state = {}
	max_health = BASE_MAX_HEALTH
	health = max_health
	production_timer.timeout.connect(_on_production_timer_timeout)


func produce_mana(amount):
	GlobalEventBus.mana_generated.emit(amount)


func _on_production_timer_timeout():
	produce_mana(1)


func _on_detectable_area_hit_by_projectile(damage) -> void:
	take_projectile_damage(damage)


func _on_detectable_area_taken_melee_hit(damage) -> void:
	take_melee_damage(damage)
