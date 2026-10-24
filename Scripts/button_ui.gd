extends Button

@export var SceneGoto = ""
@export var QuitGame = false

@export_category("Kill Node Settings")
@export var KillNode : Node
@export var EnablePlayer = false

func _process(_delta: float) -> void:

	if !button_pressed:
		return
		
	if SceneGoto != "":
		get_tree().change_scene_to_file(SceneGoto)
		
	if QuitGame:
		get_tree().quit()

	# Kill Node
	if KillNode != null:
		KillNode.queue_free()
		
		if EnablePlayer:
			Global.player_enable()
