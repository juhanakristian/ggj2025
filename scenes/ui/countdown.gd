extends Control

@onready var label: Label = $Label
@onready var timer: Timer = $Timer

@onready var car = $"../Car"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	car.controls_enabled = false

	timer.connect("timeout", Callable(self, "_on_timeout"))
	timer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if timer.is_stopped():
		return

	if timer.time_left >= 4:
		label.visible = false
		return

	var text = str(floor(timer.time_left))
	if timer.time_left < 1:
		text = "GO!"
		car.controls_enabled = true

	label.visible = true
	label.text = text

func _on_timeout():
	label.visible = false
