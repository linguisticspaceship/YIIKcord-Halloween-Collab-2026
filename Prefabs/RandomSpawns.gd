extends Node

var pages_max = 8
var current = 0

@export var collectables : Array[Node]

var random_pic = PictureData.list.keys()[randi() % PictureData.list.size()]

func _ready() -> void:
	var list = collectables #get_children()
	randomize()
	list.shuffle()
	
	for x in list:
		if current >= pages_max:
			print("Removing? ", x)
			x.queue_free()
		current += 1

	### WIP
	print ( "TEST: ", (PictureData.list[random_pic]["path"]) )
