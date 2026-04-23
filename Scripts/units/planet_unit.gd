extends Unit


const BASE_MAX_HEALTH = 60


func _init() -> void:
	unit_type = "Earth"


func _ready() -> void:
	super._ready()
	process_state = {}
	max_health = BASE_MAX_HEALTH
	health = max_health


func _on_detectable_area_hit_by_projectile(damage) -> void:
	take_projectile_damage(damage)


func _on_detectable_area_taken_melee_hit(damage) -> void:
	take_melee_damage(damage)
