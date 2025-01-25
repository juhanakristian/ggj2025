extends Control

@onready var label: Label = $Label
@onready var lap1_label: Label = $Lap1Label
@onready var lap2_label: Label = $Lap2Label
@onready var lap3_label: Label = $Lap3Label
@onready var car = $"../Car"

var time_running = false
var time = 0.0
var lap_times = []
var max_laps = 3

func start_time():
	if !time_running:
		time_running = true
		time = 0.0

func stop_time():
	time_running = false

func reset_time():
	time = 0.0
	label.text = "00:00"
	lap1_label.text = ""
	lap2_label.text = ""
	lap3_label.text = ""

func record_lap_time():
	if time_running:
		var formatted_time = format_time(time)
		lap_times.append(formatted_time)

func format_time(ftime: float) -> String:
	var minutes = int(ftime) / 60
	var seconds = int(ftime) % 60
	var milliseconds = int((ftime - int(ftime)) * 1000)
	return str(minutes).pad_zeros(2) + ":" + str(seconds).pad_zeros(2) + ":" + str(milliseconds).pad_zeros(3)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	reset_time()
	car.connect("lap_completed", Callable(self, "_on_lap_completed"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if time_running:
		time += delta
		label.text = format_time(time)

	for i in range(lap_times.size()):
		var lap_label = get_node("Lap%dLabel" % (i + 1))
		lap_label.text = "Lap %d: %s" % [i + 1, lap_times[i]]

func _on_lap_completed() -> void:
	record_lap_time()
	reset_time()

	if lap_times.size() >= max_laps:
		stop_time()
		car.emit_signal("toggle_controls", false)
