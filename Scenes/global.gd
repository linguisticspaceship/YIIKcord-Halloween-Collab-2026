extends Node

var audio_generic = preload("res://Prefabs/audio generic.tscn")
var debug_mode = true
@onready var gamecont = $"Game Controller"

# TODO: Whenever the scene changes, delete all of the sounds in Current Audio. (Or maybe just the sounds that are set in loop mode)

# If multiple filenames are listed, one will be selected randomly.
var sound_list = {
	"jumpscare": "res://Sounds/Jumpscare.ogg",
	"grass": [
		"res://Sounds/Grass_1.ogg",
		"res://Sounds/Grass_2.ogg",
		"res://Sounds/Grass_3.ogg",
		"res://Sounds/Grass_4.ogg",
		"res://Sounds/Grass_5.ogg",
	],
	"forest": "res://Sounds/forest ambience.ogg",
	"paper_pickup": "res://Sounds/Text Box Appears.ogg",
}

# Maybe move this to player script? idk
func page_counter_show(author=""):
	$Player/UI/Collect.visible = true
	$Player/UI/Collect/PageCounter.text = str(gamecont.pages_collected) + "/" + str(gamecont.page_goal) + " Pages"
	$Player/UI/Collect/Author.text = author
	$Player/UI/Collect/Timer.start()

func _process(_delta: float) -> void:
	if debug_mode:
		debug_functions()
		
		
var debug_respawntime = 0
var debug_despawntime = 0
var debug_roryactive = false
func debug_functions():
	debug_cam() # Press 5 to toggle bird view
		
	# Player UI
	var test = "WHATEVER"
		
	$Player/UI/Container/DEBUGINFO.visible = true
	$Player/UI/Container/DEBUGINFO/DebugText.text = "
	[Debug]
	CatActive = "   + str(debug_roryactive) + "
	RespawnTime = " + str(snapped(debug_respawntime,0.01)) + "
	DespawnTime = " + str(snapped(debug_despawntime,0.01)) + "
	"

func debug_cam():
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
	node.loop = loop
	node.volume_db = volume_db
	node.play()
