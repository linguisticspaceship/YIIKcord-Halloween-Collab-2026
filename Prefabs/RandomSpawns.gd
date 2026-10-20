extends Node

var pages_max = 8
var current = 0

@export var collectables : Array[Node]

func _ready() -> void:
	var list = collectables #get_children()
	randomize()
	list.shuffle()
	
	for x in list:
		if current >= pages_max:
			print(current)
			remove_child(x)
		current += 1
