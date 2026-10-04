extends Node

var audio_generic = preload("res://Prefabs/audio generic.tscn")


var sound_list = {
	"jumpscare": "res://Sounds/Jumpscare.ogg",
	"grass": [
		"res://Sounds/Grass_1.ogg",
		"res://Sounds/Grass_2.ogg",
		"res://Sounds/Grass_3.ogg",
		"res://Sounds/Grass_4.ogg",
		"res://Sounds/Grass_5.ogg",
	]
}

func find_sound_filename(sound): # Returns sound filename, so the audiostream can play it
	var sfx_request = sound_list[sound.to_lower()]
	if sfx_request == null:
		print("ERROR! ", sound, " does not exist! Not playing SFX.")
		return null
		
	# If sound has more than one listed
	if typeof(sfx_request) == TYPE_ARRAY:
		sfx_request = sfx_request.pick_random()
	
	return sfx_request

func get_sound(sound="jumpscare"): # True/false if SFX is playing
	# We get all the current SFX names in a list, then check if the sound we want is in there.
	var audio_playing = [ ]
	
	for x in $"/root/Global/Current Audio".get_children():
		audio_playing.append(x.sound_name)

	if sound in audio_playing:
		return true

	return false # Default answer
	
func play_sound(sound="jumpscare"):
	var sfx_filename = find_sound_filename(sound)
	
	var node = audio_generic.instantiate()
	get_node("/root/Global/Current Audio").add_child(node)

	node.name = sound
	node.sound_name = sound
	node.stream = load(sfx_filename)
	node.play()
