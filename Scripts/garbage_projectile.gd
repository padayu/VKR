extends Node2D


@onready var hitbox = $Hitbox
@onready var sprite = $Sprite


const BASE_DAMAGE = 3
const BASE_SPEED = 160
const BASE_ROTATION_SPEED = 1.5
const BASE_DIRECTION = Vector2(-1, 0)
const MAX_LIFETIME = 2


var lifetime = 0


var sprites = [
	preload("res://Assets/Images/Projectiles/Garbage1.png"), 
	preload("res://Assets/Images/Projectiles/Garbage2.png"), 
	preload("res://Assets/Images/Projectiles/Garbage3.png")
	]


func _ready():
	sprite.texture = sprites[randi_range(0, len(sprites) - 1)]


func _process(delta: float) -> void:
	position += BASE_DIRECTION * BASE_SPEED * delta
	rotate(BASE_ROTATION_SPEED * delta)
	lifetime += delta
	if lifetime > MAX_LIFETIME:
		queue_free()


func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.has_method("collide_with_projectile"):
		area.collide_with_projectile(BASE_DAMAGE)
		break_from_impact()


func break_from_impact():
	queue_free()
