extends AudioStreamPlayer

var loop = false
var sound_name = "null"

func _on_finished() -> void:
	if not loop:
		queue_free()
