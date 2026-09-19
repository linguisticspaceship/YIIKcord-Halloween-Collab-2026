extends Node

var sound_list = {
	"jumpscare": "res://Sounds/Jumpscare.ogg",
}

func play_sound(sound="Jumpscare"):
	var sfx_request = sound_list[sound.to_lower()]
	if sfx_request == null:
		print("ERROR! ", sound, " does not exist! Not playing SFX.")
		return
	$Sounds.stream = load(sfx_request)
	$Sounds.play()
