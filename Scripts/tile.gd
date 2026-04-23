extends Node2D
class_name Tile


enum TileTypes {NONE, LAWN, STONE}


signal hovered
signal unhovered
signal clicked


var TypeNames = {
	"lawn": TileTypes.LAWN,
	"stone": TileTypes.STONE
}
var TypeNamesRevarse = {
	TileTypes.LAWN: "lawn",
	TileTypes.STONE: "stone"
}
var field
var occupying_unit = null


@export var grid_x = 0
@export var grid_y = 0
@export var tile_type = TileTypes.NONE


@onready var sprite = $Area2D/Sprite
@onready var area_2d = $Area2D


var pending_texture


func get_tile_type_string():
	return TypeNamesRevarse[tile_type]


# save correct image to self.pending_texture
# to apply self.pending_texture to the sprite, use UpdateSprite
#--------EXPLANATION-----------------
# these two methods are separated because the sprite nodemay not exist yet
# when the texture is first decided
func SetCorrectTexture():
	var texture
	if self.tile_type == TileTypes.LAWN:
		if (self.grid_x + self.grid_y) % 2:
			texture = load("res://Assets/Images/Tiles/lawn1.png")
		else:
			texture = load("res://Assets/Images/Tiles/lawn2.png")
	elif self.tile_type == TileTypes.STONE:
		texture = load("res://Assets/Images/Tiles/stone1.png")
	self.pending_texture = texture


func deploy(tile_type_, x, y, field_):
	self.field = field_
	self.grid_x = x
	self.grid_y = y
	self.tile_type = TypeNames[tile_type_]
	z_index -= 1
	SetCorrectTexture()


func _ready() -> void:
	UpdateSprite()


func _on_area_2d_mouse_entered() -> void:
	hovered.emit(self)


func _on_area_2d_mouse_exited() -> void:
	unhovered.emit(self)


@warning_ignore("unused_parameter")
func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		clicked.emit(self)


func spawn_unit(unit_data):
	var unit = load(unit_data["path"]).instantiate()
	get_parent().add_unit(unit)
	unit.position = position
	self.occupying_unit = unit
	unit.set_occupied_tile(self)
	unit.promoted.connect(_on_unit_promoted)


func UpdateSprite():
	sprite.texture = pending_texture


func change_type(new_type: String):
	tile_type = TypeNames[new_type]
	SetCorrectTexture()
	UpdateSprite()


func _on_unit_promoted(new_type):
	var new_unit_data = GlobalUnitDatabase.units[new_type]
	occupying_unit.queue_free()
	spawn_unit(new_unit_data)
