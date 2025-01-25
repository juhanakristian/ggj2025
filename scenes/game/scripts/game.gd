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
	load_track(game_data.track)
	
## Initializes the race
## Called once based on its state, 
func init_race():
	# Emits signal for hiding the loading_screen from the Main scene.
	game_scene_loaded.emit()
	state = GameState.WAITING_START
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
	
	
	
