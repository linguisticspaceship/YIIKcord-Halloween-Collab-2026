extends Button

@export var SceneGoto = ""
@export var QuitGame = false
@export var Link = "" # Example: www.ONISM1999.com
@export var Confirmation = false
@export var ConfirmationMessage = "Are you sure?"

@export_category("Kill Node Settings")
@export var KillNode : Node
@export var EnablePlayer = false

var ConfirmPrefab = preload("res://Scenes/ButtonConfirmation.tscn")

func _process(_delta: float) -> void:
	pass

func _on_pressed() -> void:

	#if !button_pressed:
	#	return
	
	# This is stupid, doesn't work anyway
	if Confirmation:
		var instance = ConfirmPrefab.instantiate()
		instance.copiedSceneGoto = SceneGoto
		instance.copiedQuitGame = QuitGame
		instance.copiedConfirmation = Confirmation
		instance.copiedConfirmationMessage = ConfirmationMessage
		instance.copiedKillNode = KillNode
		instance.copiedEnablePlayer = EnablePlayer
		self.add_child(instance)
		return
		
	if Link != "":
		print("Clicked!")
		OS.shell_open(Link)
		
	if SceneGoto != "":
		for x in get_node("/root/Global/Current Audio").get_children():
			x.queue_free()
		get_tree().change_scene_to_file(SceneGoto)
		
	if QuitGame:
		get_tree().quit()

	# Kill Node
	if KillNode != null:
		KillNode.queue_free()
		
		if EnablePlayer:
			Global.player_enable()
