@tool

extends Node3D

@export var nodes: Array[String]

@export_tool_button("Randomize", "Callable") var random = randomize_prefabs

func randomize_prefabs():
	for x in get_children():
		#var rng_select = String(nodes[ randi_range(0, nodes.size()-1) ])
		var rng_select = nodes.pick_random() #"res://Models/tree.fbx"
		var prefab = load( rng_select )
		var instance = prefab.instantiate()
		instance.position = x.position
		x.add_sibling(instance)
		instance.owner = get_tree().edited_scene_root
		x.queue_free()
	pass
