extends Node

var pages_collected = 0
var page_goal = 8

var pictures_current = [ ] # What pictures are currently in the scene?

func _process(_delta: float) -> void:
	if pages_collected == page_goal:
		if get_node_or_null("/root/TestArea/RoryCat") != null:
			$"/root/TestArea/RoryCat".queue_free()
		if get_node_or_null("/root/TestLevel/RoryCat") != null:
			$"/root/TestLevel/RoryCat".queue_free()
			
			Global.player_disable()
			
			var button_prefab = load("res://Prefabs/button_ui.tscn") # Hacky
			var instance = button_prefab.instantiate()
			instance.visible = false
			instance.SceneGoto = "res://Scenes/GoodEnding.tscn"
			add_child(instance)
			instance._on_pressed()

func reset():
	pages_collected = 0
	pictures_current = [ ]
