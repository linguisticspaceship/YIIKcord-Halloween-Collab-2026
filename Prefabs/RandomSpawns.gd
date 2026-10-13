extends Node

var pages_max = 8
var current = 0

func _ready() -> void:
	var list = get_children()
	randomize()
	list.shuffle()
	
	for x in list:
		if current >= pages_max:
			print(current)
			remove_child(x)
		current += 1
