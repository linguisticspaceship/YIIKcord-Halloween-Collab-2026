extends Node

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
func get_sound(sound="jumpscare"): # True/false if SFX is playing
	var sfx_current = str($Sounds.stream.resource_path) # Current SFX playing
	
	# Error handler
	if sfx_current == null:
		print("No sound currently streaming.")
		return false
	
	if $Sounds.playing == false:
		#print("No sound currently playing.")
		return false
		
	if sound_list.has(sound) == false:
		print(sound, " doesn't exist in sound list.")
		return false
	
	# Main shit
	if typeof(sound_list[sound]) == TYPE_ARRAY: # "Random" sounds
		for x in sound_list[sound]:
			if x == sfx_current:
				return true
	if typeof(sound_list[sound]) == TYPE_STRING: # "Normal" Sounds
		if sound_list[sound] == sfx_current:
			return true
	
	return false # Default answer

func play_sound(sound="jumpscare"):
	var sfx_request = sound_list[sound.to_lower()]
	print(sfx_request)
	if sfx_request == null:
		print("ERROR! ", sound, " does not exist! Not playing SFX.")
		return
	
	# If sound has more than one listed
	if typeof(sfx_request) == TYPE_ARRAY:
		sfx_request = sfx_request.pick_random()
		
	$Sounds.stream = load(sfx_request)
	$Sounds.play()
