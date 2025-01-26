class_name CountDown extends Control

@onready var label: Label = $Label
@onready var timer: Timer = $Timer
@onready var car = $"../Car"
@onready var time = $"../Time"

@export var game: Node

#signal start_countdown()
signal countdown_complete()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#car.controls_enabled = false

	timer.timeout.connect(_on_timeout)
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
		time.start_time()
		
		# Disabled ( Signal does not exist, and called always when race is on?)
		#emit_signal("countdown_ended")

	label.visible = true
	label.text = text

func _on_timeout():
	label.visible = false
	

func start_countdown():
	timer.start()
