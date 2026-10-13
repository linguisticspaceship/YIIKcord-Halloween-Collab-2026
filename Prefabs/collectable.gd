extends Node3D

@onready var material = $MeshInstance3D.mesh.material

var hovered = false # If mouse on me.

var random_pic = PictureData.list.keys()[randi() % PictureData.list.size()]

func _ready() -> void:
	#randomize()
	material.albedo_texture = load(PictureData.list[random_pic]["path"])
	
func _process(_delta: float) -> void:
	if hovered && Input.is_action_pressed("Interact"):
		Global.play_sound("paper_pickup")
		Global.gamecont.pages_collected += 1
		Global.page_counter_show( PictureData.list[random_pic]["author"] )
		queue_free()

func _on_area_3d_area_entered(area: Area3D) -> void:
	if area.name == "PlayerGrab":
		hovered = true
		
func _on_area_3d_area_exited(area: Area3D) -> void:
	if area.name == "PlayerGrab":
		hovered = false
