extends Node3D

var spawn_node
@onready var player = $"/root/Global/Player"

func _ready() -> void:
	Global.player_enable() # If this script exists we assume this is a playable level.
	
	var list = get_children()
	randomize()
	list.shuffle()
	
	print(list)
	
	spawn_node = list[0]

	if player == null:
		print("Player not detected!")
	if player != null:
		player.position = list[0].position
		player.apply_floor_snap()
