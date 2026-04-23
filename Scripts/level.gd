extends Node2D


var camera_zoom: Vector2

@onready var level_loader = $LevelLoader
@onready var wave_scheduler = $WaveScheduler
@onready var game_field = $GameField
@onready var camera: Camera2D = $Camera
@onready var end_level_panel = $GameGUI/EndLevelPanel
@onready var victory_label = $GameGUI/EndLevelPanel/HBoxContainer/Victory
@onready var defeat_label = $GameGUI/EndLevelPanel/HBoxContainer/Defeat


func SetCameraZoom(zoom: Vector2):
	camera_zoom = zoom


func _ready() -> void:
	camera.zoom = camera_zoom


func _on_game_field_all_enemies_eliminated() -> void:
	win()


func win():
	end_level_panel.visible = true
	victory_label.visible = true


func lose():
	end_level_panel.visible = true
	defeat_label.visible = true


func go_back_to_main_menu():
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")


func _on_back_to_menu_pressed() -> void:
	go_back_to_main_menu()


func _on_field_border_area_entered(area) -> void:
	lose()


func _on_pause_button_pressed() -> void:
	get_tree().paused = !get_tree().paused


func _on_quit_button_pressed() -> void:
	go_back_to_main_menu()
