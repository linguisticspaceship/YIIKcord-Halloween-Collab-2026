extends Node3D

@onready var material_front = $MeshInstance3DFront.mesh.material
@onready var material_back = $MeshInstance3DBack.mesh.material

var hovered = false # If mouse on me.

var random_pic = PictureData.list.keys()[randi() % PictureData.list.size()]

func _ready() -> void:
	#randomize()
	material_front.albedo_texture = load(PictureData.list[random_pic]["path"])
	material_back.albedo_texture = material_front.albedo_texture
	
	# Resize mesh depending on image size
	var texture_width = float(material_front.albedo_texture.get_width())
	var texture_height = float(material_front.albedo_texture.get_height())
	var formula = (texture_width / texture_height) - 1
	$MeshInstance3DFront.mesh.size.x += formula
	$MeshInstance3DBack.mesh.size.x += formula
	
func _process(_delta: float) -> void:
	if hovered && Input.is_action_just_pressed("Interact"):
		Global.save("gallery_unlocked",random_pic,true)
		
		$"/root/Global/Player/UI/Collect/SubViewportContainer/SubViewport/SpinningPicture".texture = material_front.albedo_texture
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
