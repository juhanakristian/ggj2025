class_name Game extends Node

## Signals used communicating with the Main scene
signal game_scene_loaded()
signal game_scene_exit()

## State for dynamically loading the track 
enum GameState {ERROR, INIT, LOADING_TRACK, INIT_RACE, WAITING_START, RACE, FINISH}    

## Track related defintions
var track_resource : Track = null
var track_scene : TrackScene = null
var track_loading_progress = [0.0]

# Game state
@export var game_data : GameData
var state : GameState = GameState.INIT

@export var car : Node
@export var time_system : TimeSystem
@export var countdown : CountDown
@onready var race_result_view: RaceResultView = $RaceResultView

## Starts loading the track
func load_track(track : Track):
	# TODO: Release the track if already loaded
	state = GameState.LOADING_TRACK
	print("Game::load_track -> Starting resource loader with path:%s" % track.track_scene.resource_path) 
	track_resource = track
	ResourceLoader.load_threaded_request(track.track_scene.resource_path)
	
## Processes the track loading
## Checks current status of the threaded loading and inits the loaded track 
func process_track_loading():
	assert(state == GameState.LOADING_TRACK, "Game::process_track_loading called with non-loading state")
	var loading_status = ResourceLoader.load_threaded_get_status(
		track_resource.track_scene.resource_path, 
		track_loading_progress
	)
	
	match loading_status:
		ResourceLoader.ThreadLoadStatus.THREAD_LOAD_IN_PROGRESS:
			print("Game::process_track_loading -> Loading track %s%" % (track_loading_progress * 100))
			
		ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
			print("Game::process_track_loading -> Track loading finished")
			var loaded_scene = ResourceLoader.load_threaded_get(track_resource.track_scene.resource_path)
			track_scene = loaded_scene.instantiate()
			add_child(track_scene)
			## TODO: Get all required things from the track, start,checkopoints, etc.
			state = GameState.INIT_RACE
			

		ResourceLoader.ThreadLoadStatus.THREAD_LOAD_INVALID_RESOURCE:
			printerr("Main: process_view_loading -> THREAD_LOAD_INVALID_RESOURCE")
			state = GameState.ERROR
			
		ResourceLoader.ThreadLoadStatus.THREAD_LOAD_FAILED:
			printerr("Main: process_view_loading -> THREAD_LOAD_FAILED")
			state = GameState.ERROR


func _ready():
	print("Game::_ready -> Starting load_track: %s" % game_data)
	countdown.connect("countdown_complete", Callable(self, "_on_countdown_complete"))
	countdown.countdown_complete.connect(_on_countdown_complete)
	time_system.connect("race_complete", Callable(self, "_on_race_complete"))
	load_track(game_data.track)
	
## Initializes the race
## Called once based on its state, 
func init_race():
	# Emits signal for hiding the loading_screen from the Main scene.
	game_scene_loaded.emit()
	state = GameState.WAITING_START
	car.emit_signal("reset_car")
	car.controls_enabled = false
	time_system.emit_signal("init_time")
	countdown.emit_signal("start_countdown")
	countdown.start_countdown()
	race_result_view.visible = false
	print("Game::init_race -> Race initialized, waiting for start")
	

func _process(_delta: float) -> void:
	
	match state:
		GameState.LOADING_TRACK:
			return process_track_loading()
		GameState.INIT_RACE:
			init_race()
	
	#TODO: Map the action (ui_cancel = Esc)
	if Input.is_action_just_pressed("ui_cancel"): 
		print("Game::_process UI Cancel was just pressed")
		game_scene_exit.emit()	

	# Logic before RaceResultView
	#if Input.is_action_just_pressed("reset") and state == GameState.FINISH:
	#	print("Game::_process Reset was just pressed")
	#	state = GameState.INIT_RACE
	
	
func _on_countdown_complete():
	state = GameState.RACE
	print("Game::_on_countdown_complete -> State changed to: %s" % state)

func _on_race_complete():
	state = GameState.FINISH
	print("Game::_on_race_complete -> State changed to: %s" % state)
	race_result_view.visible = true
	race_result_view.set_best_time(time_system.best_time)
	race_result_view.set_prev_time(time_system.best_lap_time)

## Player wants to race again
func _on_race_result_view_player_start_race() -> void:
	state = GameState.INIT_RACE


func _on_race_result_view_player_exit_to_menu() -> void:
	game_scene_exit.emit()	
