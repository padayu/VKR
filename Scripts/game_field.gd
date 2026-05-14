extends Node2D


var n_rows = 0
var n_columns = 0
var tiles = []
var true_height
var true_width
var tile_gap
var currently_hovered_tile = null
var currently_selected_unit_card: UnitCard = null
var more_enemies_will_spawn = true
var enemies_on_the_field = 0
var editor_tile_type_selected = null


const FIELD_WIDTH = 1400.0
const FIELD_HEIGHT = 800.0
const TILE_HEIGHT = 107.0
const TILE_WIDTH = 150.0


signal mana_payment_needed
signal all_enemies_eliminated
signal move_and_resize_field_border
signal on_add_unit
signal tile_added


var tile_scene: PackedScene = preload("res://Scenes/tile.tscn")


@onready var unit_field_preview = $UnitFieldPreview
@onready var field_border = $FieldBorder
@onready var units = $Units
@onready var enemies = $Enemies
@onready var tiles_node = $Tiles
@onready var projectiles = $Projectiles
@onready var decorations = $Decorations


func _ready():
	GenerateBackground()


func CalculateScale():
	true_height = TILE_HEIGHT * n_rows + TILE_HEIGHT * tile_gap * (n_rows - 1)
	true_width = TILE_WIDTH * n_columns + TILE_WIDTH * tile_gap * (n_columns - 1)
	return min(FIELD_HEIGHT / true_height, FIELD_WIDTH / true_width)


func CalculateTilePosition(x, y) -> Vector2:
	var tile_x = x * (TILE_WIDTH + TILE_WIDTH * tile_gap) + TILE_WIDTH / 2 - true_width / 2
	var tile_y = y * (TILE_HEIGHT + TILE_HEIGHT * tile_gap) + TILE_HEIGHT / 2 - true_height / 2
	return Vector2(tile_x, tile_y)


func LoadTiles(field_data):
	var tile_data = field_data["tiles"]
	for y in range(n_rows):
		self.tiles.append([])
		for x in range(n_columns):
			var tile_type = tile_data[y][x]
			var new_tile = tile_scene.instantiate()
			tile_added.emit(new_tile)
			register_tile_events(new_tile)
			self.tiles[-1].append(new_tile)
			new_tile.deploy(tile_type, x, y, self)
			new_tile.position = CalculateTilePosition(x, y)


func LoadData(field_data):
	self.n_columns = field_data["x"]
	self.n_rows = field_data["y"]
	self.tile_gap = field_data["gap"]
	
	var calculated_scale = CalculateScale()
	get_parent().SetCameraZoom(Vector2(calculated_scale, calculated_scale))
	LoadTiles(field_data)
	place_field_border()
	
	var units_data = field_data["units"]
	for unit in units_data:
		var unit_data = GlobalUnitDatabase.units[unit["type"]]
		tiles[unit["grid_y"]][unit["grid_x"]].spawn_unit(unit_data)


func register_tile_events(tile):
	tile.hovered.connect(_on_tile_hovered)
	tile.unhovered.connect(_on_tile_unhovered)
	tile.clicked.connect(_on_tile_clicked)


func place_field_border():
	move_and_resize_field_border.emit(CalculateTilePosition(-2, n_rows + 3), CalculateTilePosition(-2, -3))

func _on_tile_hovered(tile):
	currently_hovered_tile = tile
	update_unit_field_preview()


func _on_tile_unhovered(tile):
	if currently_hovered_tile == tile:
		currently_hovered_tile = null
		update_unit_field_preview()


func _on_tile_clicked(tile):
	# Deploy unit
	if tile.occupying_unit == null and currently_selected_unit_card != null:
		currently_selected_unit_card.start_cooldown()
		deploy_unit(tile)
	# Edit tile type
	elif editor_tile_type_selected != null:
		tile.change_type(editor_tile_type_selected)


func deploy_unit(tile):
	pay_cost(currently_selected_unit_card.unit)
	tile.spawn_unit(currently_selected_unit_card.unit)
	currently_selected_unit_card.set_pressed(false)
	currently_selected_unit_card = null
	update_unit_field_preview()


func pay_cost(unit):
	mana_payment_needed.emit(unit["cost"])


# unit field preview is the semi-transparent image of the unit that appears on the hovered tile
func update_unit_field_preview():
	if currently_hovered_tile == null or currently_hovered_tile.occupying_unit != null:
		unit_field_preview.visible = false
	else:
		unit_field_preview.visible = true
		unit_field_preview.position = CalculateTilePosition(
			currently_hovered_tile.grid_x, 
			currently_hovered_tile.grid_y,
			)
	if currently_selected_unit_card == null:
		unit_field_preview.texture = null
	else:
		unit_field_preview.texture = load(currently_selected_unit_card.unit["image"])


func spawn_enemy(enemy, spawn_position):
	var new_enemy = enemy.instantiate()
	enemies.add_child(new_enemy)
	new_enemy.position = spawn_position
	new_enemy.z_index = ZIndexByY(spawn_position.y)
	new_enemy.died.connect(_on_enemy_died)
	enemies_on_the_field += 1


func add_unit(unit):
	on_add_unit.emit(unit)


func _on_enemy_died():
	enemies_on_the_field -= 1
	if enemies_on_the_field == 0 and not more_enemies_will_spawn:
		all_enemies_eliminated.emit()


func _on_unit_loadout_selected_unit_card(card) -> void:
	currently_selected_unit_card = card
	update_unit_field_preview()


func _on_wave_manager_spawn_enemy_in_row(enemy, row) -> void:
	var spawn_position = CalculateTilePosition(n_columns + 2, row)
	spawn_enemy(enemy, spawn_position)


func _on_wave_manager_no_more_timed_waves() -> void:
	more_enemies_will_spawn = false


func ExtractData():
	var data = {}
	data["x"] = n_columns
	data["y"] = n_rows
	data["gap"] = tile_gap
	var tile_data = []
	for row in tiles:
		var row_data = []
		for tile in row:
			row_data.append(tile.get_tile_type_string())
		tile_data.append(row_data)
	data["tiles"] = tile_data
	var unit_data = []
	for unit in units.get_children():
		unit_data.append(unit.get_data())
	data["units"] = unit_data
	return data


func _on_editor_gui_on_editor_tile_type_changed(tile_type) -> void:
	editor_tile_type_selected = tile_type


func AddProjectile(projectile):
	projectiles.add_child(projectile)


func ZIndexByY(y):
	return true_height + y


func GenerateBackground():
	
	# Clear old decorations if present
	for child in decorations.get_children():
			child.queue_free()
	
	# Spawn top and bottom bg
	for col in range(-n_columns / 2 - 5, 1.5 * n_columns + 5):
		
		var bg_forest_sprite = Sprite2D.new()
		bg_forest_sprite.texture = load("res://Assets/Images/Decorations/Firs2.png")
		var pos = CalculateTilePosition(col, -1)
		pos.y -= (150 - (TILE_HEIGHT / 2))
		bg_forest_sprite.position = pos
		bg_forest_sprite.z_index = -2
		decorations.add_child(bg_forest_sprite)
		
		var bg_river_sprite = Sprite2D.new()
		bg_river_sprite.texture = load("res://Assets/Images/Decorations/River.png")
		pos = CalculateTilePosition(col, n_rows)
		pos.y += (250 - (TILE_HEIGHT / 2))
		bg_river_sprite.position = pos
		bg_river_sprite.z_index = -2
		decorations.add_child(bg_river_sprite)
		
	# Spawn left and right bg
	for row in range(n_rows):
		
		var bg_left_grass_sprite = Sprite2D.new()
		bg_left_grass_sprite.texture = load("res://Assets/Images/Decorations/Grass.png")
		var pos = CalculateTilePosition(-1, row)
		pos.x -= (250 - (TILE_WIDTH / 2))
		bg_left_grass_sprite.position = pos
		decorations.add_child(bg_left_grass_sprite)
		
		bg_left_grass_sprite = Sprite2D.new()
		bg_left_grass_sprite.texture = load("res://Assets/Images/Decorations/Grass.png")
		pos = CalculateTilePosition(-3, row)
		pos.x -= (250 - (TILE_WIDTH / 2))
		bg_left_grass_sprite.position = pos
		decorations.add_child(bg_left_grass_sprite)
		
		var bg_right_grass_sprite = Sprite2D.new()
		bg_right_grass_sprite.texture = load("res://Assets/Images/Decorations/Grass.png")
		pos = CalculateTilePosition(n_columns, row)
		pos.x += (250 - (TILE_WIDTH / 2))
		bg_right_grass_sprite.position = pos
		decorations.add_child(bg_right_grass_sprite)
		
		bg_right_grass_sprite = Sprite2D.new()
		bg_right_grass_sprite.texture = load("res://Assets/Images/Decorations/Grass.png")
		pos = CalculateTilePosition(n_columns + 2, row)
		pos.x += (250 - (TILE_WIDTH / 2))
		bg_right_grass_sprite.position = pos
		decorations.add_child(bg_right_grass_sprite)
		
		var bg_left_bush_sprite = Sprite2D.new()
		if row % 2:
			bg_left_bush_sprite.texture = load("res://Assets/Images/Decorations/Bush1.png")
		else:
			bg_left_bush_sprite.texture = load("res://Assets/Images/Decorations/Bush2.png")
		pos = CalculateTilePosition(-1, row)
		bg_left_bush_sprite.z_index = ZIndexByY(pos.y + TILE_HEIGHT / 2)
		pos.x -= (250 - (TILE_WIDTH / 2))
		pos.y -= (145 - (TILE_HEIGHT / 2))
		bg_left_bush_sprite.position = pos
		decorations.add_child(bg_left_bush_sprite)
		
		var bg_right_bush_sprite = Sprite2D.new()
		if row % 2:
			bg_right_bush_sprite.texture = load("res://Assets/Images/Decorations/Bush1.png")
		else:
			bg_right_bush_sprite.texture = load("res://Assets/Images/Decorations/Bush2.png")
		pos = CalculateTilePosition(n_columns, row)
		bg_right_bush_sprite.z_index = ZIndexByY(pos.y + TILE_HEIGHT / 2)
		pos.x += (250 - (TILE_WIDTH / 2))
		pos.y -= (145 - (TILE_HEIGHT / 2))
		bg_right_bush_sprite.position = pos
		decorations.add_child(bg_right_bush_sprite)


func _on_field_size_field_size_changed(new_x, new_y) -> void:
	AdjustFieldSize(new_x, new_y)


func AdjustFieldSize(new_x, new_y):
	
	for child in [enemies, units, projectiles]:
		child.position.x += (n_columns - new_x) * TILE_WIDTH / 2.0
		child.position.y += (n_rows - new_y) * TILE_HEIGHT / 2.0
	
	n_columns = new_x
	n_rows = new_y
	
	if len(tiles) > n_rows:
		for row_y in range(n_rows, len(tiles)):
			for tile in tiles[row_y]:
				tile.delete()
		tiles.resize(n_rows)
	
	while len(tiles) < new_y:
		tiles.append([])
		for cell_x in range(new_x):
			var tile_type = "lawn"
			var new_tile = tile_scene.instantiate()
			tiles_node.add_child(new_tile)
			register_tile_events(new_tile)
			tiles[-1].append(new_tile)
			new_tile.deploy(tile_type, cell_x, len(tiles) - 1, self)
	
	for row_y in range(len(tiles)):
		var row = tiles[row_y]
		if len(row) > new_x:
			for cell_x in range(new_x, len(row)):
				row[cell_x].delete()
			row.resize(new_x)
		elif len(row) < new_x:
			for cell_x in range(len(row), new_x):
				var tile_type = "lawn"
				var new_tile = tile_scene.instantiate()
				tiles_node.add_child(new_tile)
				register_tile_events(new_tile)
				row.append(new_tile)
				new_tile.deploy(tile_type, cell_x, row_y, self)
	
	var calculated_scale = CalculateScale()
	get_parent().SetCameraZoom(Vector2(calculated_scale, calculated_scale))
	GenerateBackground()
	
	for row_y in range(n_rows):
		for cell_x in range(n_columns):
			tiles[row_y][cell_x].position = CalculateTilePosition(cell_x, row_y)
