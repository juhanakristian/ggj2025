extends Control

# label
@onready var label: Label = $Label

var time_running = false
var time = 0.0

func start_time():
	if !time_running:
		time_running = true
		time = 0.0

func stop_time():
	time_running = false

func reset_time():
	time = 0.0
	label.text = "00:00"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	reset_time()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if time_running:
		time += delta
		var minutes = int(time) / 60
		var seconds = int(time) % 60
		var milliseconds = int((time - int(time)) * 1000)
		label.text = str(minutes).pad_zeros(2) + ":" + str(seconds).pad_zeros(2) + ":" + str(milliseconds).pad_zeros(3)
