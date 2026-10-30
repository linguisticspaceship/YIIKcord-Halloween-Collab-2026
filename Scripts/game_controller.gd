extends Node

var pages_collected = 0
var page_goal = 8

var pictures_current = [ ] # What pictures are currently in the scene?

func _process(_delta: float) -> void:
	if pages_collected == page_goal:
		print("You win!")

func reset():
	pages_collected = 0
	pictures_current = [ ]
