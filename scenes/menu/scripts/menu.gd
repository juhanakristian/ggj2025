class_name Menu extends Node3D

signal menu_scene_loaded() 
signal menu_start_game()

@export var game_data : GameData


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	menu_scene_loaded.emit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_game_button_pressed() -> void:
	menu_start_game.emit()


func _on_quit_game_button_pressed() -> void:
	get_tree().quit()
