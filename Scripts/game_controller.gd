extends Node

var pages_collected = 0
var page_goal = 8

func _process(delta: float) -> void:
	if pages_collected == page_goal:
		print("You win!")
