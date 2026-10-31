#@tool
extends Node

var audio_generic = preload("res://Prefabs/audio generic.tscn")
var debug_mode = false
@onready var gamecont = $"Game Controller"

var setting_mouse_sensitivity = 0.01

var settings_prefab = load("res://Scenes/Settings.tscn")

var in_game = false # Set to false in Main Menu

var rorycat_threat = true # If Rory Cat is active or not

# TODO: Whenever the scene changes, delete all of the sounds in Current Audio. (Or maybe just the sounds that are set in loop mode)

# If multiple filenames are listed, one will be selected randomly.
var sound_list = {
	"jumpscare": "res://Sounds/Jumpscare.ogg",
	"evil_meow": "res://Sounds/evil meow.ogg",
	"game_over": "res://Sounds/deathsound.ogg",
	"footstep_dirt": [
		"res://Sounds/footstep_dirt_1.ogg",
		"res://Sounds/footstep_dirt_2.ogg",
		"res://Sounds/footstep_dirt_3.ogg",
		"res://Sounds/footstep_dirt_4.ogg",
		"res://Sounds/footstep_dirt_5.ogg",
		"res://Sounds/footstep_dirt_6.ogg",
	],
	"forest": "res://Sounds/forest ambience.ogg",
	"windtown": "res://Sounds/windtown_ambience_short.ogg",
	"paper_pickup": "res://Sounds/Text Box Appears.ogg",
	"static": "res://Sounds/static.ogg",
}

var save_filepath = "user://yiikcord_halloween_2026.save"
var save_current = { } # What is currently loaded in save data
var mobile = false

func player_enable():
	settings_reload()
	in_game = true
	$"Player".process_mode = PROCESS_MODE_PAUSABLE
	$"Player".visible = true
	$"Player/UI".visible = true
	$"Player/Camera3D".current = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	# RoryCat
	#if get_node_or_null("/root/TestArea/RoryCat") != null:
	#	$"/root/TestArea/RoryCat".process_mode = PROCESS_MODE_PAUSABLE
	
func player_disable():
	$"Player".process_mode = PROCESS_MODE_DISABLED
	$"Player".visible = false
	$"Player/UI".visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	# RoryCat
	if get_node_or_null("/root/TestArea/RoryCat") != null:
		$"/root/TestArea/RoryCat".process_mode = PROCESS_MODE_DISABLED
	

# Maybe move this to player script? idk
func page_counter_show(author=""):
	#$Player/UI/Collect.visible = true
	$Player/UI/Collect/AnimationPlayer.speed_scale = 2.0
	$Player/UI/Collect/AnimationPlayer.play("Show")
	$Player/UI/Collect/PageCounter.text = str(gamecont.pages_collected) + "/" + str(gamecont.page_goal) + " Pages"
	$Player/UI/Collect/Author.text = author
	$Player/UI/Collect/Timer.start()

# Saves current data to save file
func save_to_file():
	var save_file = FileAccess.open(save_filepath, FileAccess.WRITE)

	var json_string = JSON.stringify( save_current )
	
	save_file.store_line(json_string)

# Load data from file (We run this on startup)
func load_from_file():	
	# If data file doesn't exist
	if not FileAccess.file_exists(save_filepath):
		print("No save file detected.")
		return
		
	var save_file = FileAccess.open(save_filepath, FileAccess.READ)
	
	var json_string = save_file.get_line()
	
	# If data is blank
	if JSON.parse_string(json_string) == null:
		save_current = { }
		print("Data file is blank, fixing.")
		return
	
	save_current = JSON.parse_string(json_string)

# Saves group and key to the "current" save file.
# Example: save("gallery_unlocked","LSTest1",true)
func save(group="test_group",key="test_key",value=true):
	if not save_current.has(group):
		save_current[group] = { }
	save_current[group][key] = value
	
	save_to_file()

# Reads group and key and returns the value.
func read(group="test_group",key="test_key",default=false):
	if not save_current.has(group): # Group not found
		return default
	if not save_current[group].has(key): # Key not found
		return default
	
	return save_current[group][key]

func _input(_event: InputEvent) -> void:
	if $"Player".visible:
		if Input.is_action_just_pressed("Menu") && !get_node_or_null("/root/Global/Settings"):
			create_pause_menu()

func create_pause_menu():
	var instance = settings_prefab.instantiate()
	add_child(instance)
	player_disable()

func _ready() -> void:
	
	load_from_file()
	
	settings_reload()
	
	player_disable()
	
	# Toggle mobile controls
	if OS.has_feature("web_android") or OS.has_feature("web_ios"):
		mobile = true
		
	if mobile:
		$"Player/UI/Mobile Controls".visible = true
	else:
		$"Player/UI/Mobile Controls".visible = false
	
func settings_reload():
	setting_mouse_sensitivity = read("settings", "sensitivity", 0.01)
	$"Player".mouse_sensitivity = setting_mouse_sensitivity

func transition_show():
	$Transition/AnimationPlayer.play("show")
func transition_hide():
	$Transition/AnimationPlayer.play("hide")
func transition_between_check(): # If completely black (right time to execute code)
	if $Transition/ColorRect.modulate.a == 1.0:
		return true
	else:
		return false
func transition_any_check(): # If transition playing at all
	if $Transition/AnimationPlayer.is_playing():
		return true
	else:
		return false
	
func _process(_delta: float) -> void:
	if debug_mode:
		debug_functions()
		
var debug_respawntime = 0
var debug_despawntime = 0
var debug_roryactive = false
func debug_functions():
	debug_cam() # Press 5 to toggle bird view
		
	# Player UI
	if get_node_or_null("/root/Global/Player"):
		$Player/UI/Container/DEBUGINFO.visible = true
		$Player/UI/Container/DEBUGINFO/DebugText.text = "
		[Debug]
		CatActive = "   + str(debug_roryactive) + "
		RespawnTime = " + str(snapped(debug_respawntime,0.01)) + "
		DespawnTime = " + str(snapped(debug_despawntime,0.01)) + "
		"

func debug_cam():
	if Engine.is_editor_hint():
		return
	
	if Input.is_action_just_pressed("DebugCam"):
		if $Player/DEBUGCAM.current:
			$Player/DEBUGCAM.current = false
			return
		if !$Player/DEBUGCAM.current:
			$Player/DEBUGCAM.current = true
			return


func find_sound_filename(sound): # Returns sound filename, so the audiostream can play it
	var sfx_request = sound_list.get(sound.to_lower(), null)
	if sfx_request == null:
		print("ERROR! ", sound, " does not exist! Not playing SFX.")
		return null
		
	# If sound has more than one listed
	if typeof(sfx_request) == TYPE_ARRAY:
		sfx_request = sfx_request.pick_random()
	
	return sfx_request

func get_sound(sound="jumpscare"): # True/false if SFX is playing
	# We get all the current SFX names in a list, then check if the sound we want is in there.
	var audio_playing = []
	
	for x in $"/root/Global/Current Audio".get_children():
		audio_playing.append(x.sound_name)

	if sound in audio_playing:
		return true

	return false # Default answer
	
func play_sound(sound="jumpscare",loop=false,volume_db=0.0):
	var sfx_filename = find_sound_filename(sound)
	if sfx_filename == null:
		return
	
	var node = audio_generic.instantiate()
	get_node("/root/Global/Current Audio").add_child(node)

	node.name = sound
	node.sound_name = sound
	node.stream = load(sfx_filename) 
	node["parameters/looping"] = loop
	node.volume_db = volume_db
	node.play()
