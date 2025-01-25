class_name Main extends Node

const LOADING_SCREEN = preload("res://scenes/main/loading_screen/loading_screen.tscn")

const GAME_SCENE_PATH : String = "res://scenes/game/game.tscn"
const MENU_SCENE_PATH : String = "res://scenes/menu/menu.tscn"

enum MainState {INIT, LOADING_MENU, MENU_READY, LOADING_GAME, GAME_READY}
enum LoadingState {LOADING, READY, ERROR }
var loading_screen : LoadingScreen = null

var main_state : MainState = MainState.INIT
var loading_state : LoadingState = LoadingState.READY


var menu_scene : Menu = null
var game_scene : Game = null

var load_scene_path : String
var load_scene_progress : Array[float]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	init_loading_screen()
	load_main_menu()
	
func init_loading_screen():
	loading_screen = LOADING_SCREEN.instantiate() 
	add_child(loading_screen)
	loading_screen.show_loading()
	

func load_main_menu():
	loading_screen.show_loading()
	print("Main::load_main_menu -> Starting")
	main_state = MainState.LOADING_MENU
	load_scene(MENU_SCENE_PATH)
	
func load_game():
	# Free the menu scene 
	menu_scene.queue_free()
	menu_scene = null
	main_state = MainState.LOADING_GAME
	load_scene(GAME_SCENE_PATH)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	match loading_state:
		LoadingState.LOADING:
			return process_scene_loading()

	match main_state:
		MainState.INIT:
			return load_main_menu()
		
	
## Starts the scene loading with load_threaded_requests
func load_scene(scene_path: String) -> void:
	print("Main::load_scene -> called with scene_path:%s" % scene_path)
	load_scene_path = scene_path
	ResourceLoader.load_threaded_request(load_scene_path)
	loading_state = LoadingState.LOADING
	
		
## Processes scene loading, called from _process (threaded)
func process_scene_loading():
	var loading_status : ResourceLoader.ThreadLoadStatus = ResourceLoader.load_threaded_get_status(
		load_scene_path,
		load_scene_progress
	)
	# Check the loaded status
	match loading_status:
		ResourceLoader.ThreadLoadStatus.THREAD_LOAD_IN_PROGRESS:
			print("Main::process_scene_loading_status -> THREAD_LOAD_IN_PROGRESS:%s", load_scene_progress[0] * 100)

		ResourceLoader.ThreadLoadStatus.THREAD_LOAD_INVALID_RESOURCE:
			printerr("Main::process_scene_loading_status -> THREAD_LOAD_INVALID_RESOURCE")
			loading_state = LoadingState.ERROR
			
		ResourceLoader.ThreadLoadStatus.THREAD_LOAD_FAILED:
			printerr("Main::process_scene_loading_status -> THREAD_LOAD_FAILED")
			loading_state = LoadingState.ERROR
			loading_screen.enable_error_mode("ERROR: THREAD_LOAD_FAILED")
			
		ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
			init_loaded_scene()
			loading_state = LoadingState.READY
			
			
func init_loaded_scene():
	print("Main::init_loaded_scene called, current path:%s" % load_scene_path)
	match load_scene_path:
		GAME_SCENE_PATH:
			init_game_scene()
		MENU_SCENE_PATH:
			init_menu_scene()


## Initializes the game_scene
## Loads the instantiates the resource 
func init_game_scene():
	var scene_resource : Resource = ResourceLoader.load_threaded_get(GAME_SCENE_PATH)
	game_scene = scene_resource.instantiate()

	# Connect signals
	game_scene.game_scene_loaded.connect(_on_scene_loaded)
	game_scene.game_scene_exit.connect(_on_game_scene_exit)
	add_child(game_scene)
	main_state = MainState.GAME_READY

## Initializes the menu scene
## Called when the process_scene_loading has finished thread based scene loading
func init_menu_scene():
	var scene_resource : Resource = ResourceLoader.load_threaded_get(MENU_SCENE_PATH)
	menu_scene = scene_resource.instantiate()
	# Connect signals
	menu_scene.menu_scene_loaded.connect(_on_scene_loaded)
	menu_scene.menu_start_game.connect(_on_start_game)
	
	# Add as child (_ready call) 
	add_child(menu_scene)
	# Set the state as menu ready
	main_state = MainState.MENU_READY
	
## Handler for signals from scenes (menu/game)
## Disables the loading_screen when invoked
func _on_scene_loaded():
	loading_screen.hide_loading()

func _on_start_game():
	print("Main::_on_start_game -> Player started game")
	load_game()
	
## handles signals from game scene (player exits)
## Used for releasing the game scene and loading main menu
func _on_game_scene_exit():
	print("Main::_on_game_scene_exit -> called, releasing game scene")
	loading_screen.show_loading()
	game_scene.queue_free()
	game_scene = null
	load_main_menu()
