class_name LoadingScreen extends CanvasLayer
@onready var loading_label: Label = $LoadingLabel

func show_loading():
	visible = true
	
func hide_loading():
	visible = false

## Enables error mode, with given message
func enable_error_mode(message : String):
	show_loading()
	loading_label.text = message
