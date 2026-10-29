extends Node

var clicked = false

@export var transition_effect = true

@export var SceneGoto = ""
@export var QuitGame = false
@export var Link = "" # Example: www.ONISM1999.com
@export var Confirmation = false
@export var ConfirmationMessage = "Are you sure?"

@export_category("Kill Node Settings")
@export var KillNode : Node
@export var EnablePlayer = false

var ConfirmPrefab = preload("res://Scenes/ButtonConfirmation.tscn")

func _on_pressed() -> void:
	# Prevents all buttons from being clicked during transition animation
	if Global.transition_any_check():
		return
	
	clicked = true
	
	if transition_effect:
		Global.transition_show()
			
func _process(_delta: float) -> void:
	if !clicked or Global.transition_any_check():
		return
		
	### PART 1: Execute button code

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
		if get_node_or_null("/root/Global/Current Audio") != null:
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
			
	### PART 2: Hide transition effect
	clicked = false
	if transition_effect:
		Global.transition_hide()
	
