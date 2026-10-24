extends Button

@export var SceneGoto = ""
@export var QuitGame = false

func _process(_delta: float) -> void:
	if !button_pressed:
		return
		
	if SceneGoto != "":
		get_tree().change_scene_to_file(SceneGoto)
		
	if QuitGame == true:
		get_tree().quit()
