@tool

extends Node

@export var prefab = load("res://Models/tree.tscn")
@export var amount = 1
@export var random_rotation : bool = true 
@onready var shape : Node = $CollisionShape3D

@export_tool_button("Sprinkle Prefabs", "Callable") var sprinkle_prefabs = populate
@export_tool_button("Clear Objects", "Callable") var clear_objs = clear_objects


func populate():	
	# Part 1 - Init Variables
	var shape_x = shape.get_shape().get_size().x
	var shape_z = shape.get_shape().get_size().z
	
	var range_x
	var range_z

	# Part 2 - Clear objects
	clear_objects()
	
	# Part 3 - Create objects
	var instance
	for x in amount:
		instance = prefab.instantiate()
		
		range_x = randf_range(0.0, shape_x)
		range_z = randf_range(-shape_z / 2, shape_z / 2) # IDK why this has to be divided, but it works
		instance.position.x = range_x
		instance.position.z = range_z
		if random_rotation:
			instance.rotation.y = randf_range(0.0, 360.0)
		instance.name = "SprinkledPrefab" + str(x)
		$Objects.add_child(instance)
		instance.owner = get_tree().edited_scene_root

func clear_objects():
	for x in $Objects.get_children():
		x.queue_free()
