extends Node2D
class_name Tile


enum TileTypes {NONE, LAWN, STONE}


signal hovered
signal unhovered
signal clicked
signal change_texture


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


@onready var sprite = $TileSprite
@onready var area_2d = $Area2D


var pending_texture


func get_tile_type_string():
	return TypeNamesRevarse[tile_type]


func SetCorrectTexture():
	var texture
	if self.tile_type == TileTypes.LAWN:
		if (self.grid_x + self.grid_y) % 2:
			texture = load("res://Assets/Images/Tiles/lawn1.png")
		else:
			texture = load("res://Assets/Images/Tiles/lawn2.png")
	elif self.tile_type == TileTypes.STONE:
		print("IWANNABESTONE")
		texture = load("res://Assets/Images/Tiles/stone1.png")
	pending_texture = texture
	change_texture.emit(texture)


func deploy(tile_type_, x, y, field_):
	print(tile_type)
	self.field = field_
	self.grid_x = x
	self.grid_y = y
	self.tile_type = TypeNames[tile_type_]
	z_index -= 1
	SetCorrectTexture()


func _ready() -> void:
	sprite.texture = pending_texture


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
	get_parent().get_parent().add_unit(unit)
	unit.position = position
	self.occupying_unit = unit
	unit.set_occupied_tile(self)
	unit.promoted.connect(_on_unit_promoted)


func change_type(new_type: String):
	tile_type = TypeNames[new_type]
	SetCorrectTexture()


func delete():
	if occupying_unit != null:
		occupying_unit.queue_free()
	queue_free()


func _on_unit_promoted(new_type):
	var new_unit_data = GlobalUnitDatabase.units[new_type]
	occupying_unit.queue_free()
	spawn_unit(new_unit_data)
