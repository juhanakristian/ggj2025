class_name RaceResultView extends Control

## View's signals (From buttons)
signal player_exit_to_menu()
signal player_start_race()


@onready var prev_time_label: Label = $Panel/VBoxContainer/MarginContainer/VBoxContainer/PrevTimeLabel
@onready var best_time_label: Label = $Panel/VBoxContainer/MarginContainer/VBoxContainer/BestTimeLabel

## Setted for time labels, when the time does not exist
@export var unknown_time_text : String = "N.A"

## Sets the default texts
func _ready() -> void:
	prev_time_label.text = unknown_time_text
	best_time_label.text = unknown_time_text
	
	# Used for testing the stand-alone-scene
	#set_best_time(32.2)
	#set_prev_time(12.0)

func format_time(ftime: float) -> String:
	var minutes = int(ftime) / 60
	var seconds = int(ftime) % 60
	var milliseconds = int((ftime - int(ftime)) * 1000)
	return str(minutes).pad_zeros(2) + "." + str(seconds).pad_zeros(2) + "." + str(milliseconds).pad_zeros(3)

func set_best_time(ftime : float):
	best_time_label.text = format_time(ftime)
	
func set_prev_time(ftime : float):
	prev_time_label.text = format_time(ftime)
	
func _on_exit_to_menu_button_pressed() -> void:
	print("RaceResultView::_on_exit_to_menu_button_pressed")
	player_exit_to_menu.emit()

func _on_start_race_button_pressed() -> void:
	print("RaceResultView::_on_race_button_pressed")
	player_start_race.emit()
