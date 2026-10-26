extends Node3D

@onready var material = $SubViewport/Sprite2D.texture
@onready var material_anim = $SubViewport/AnimatedSprite2D.animation

var hovered = false # If mouse on me.

var pic_selected = ""

var texture_width
var texture_height

func select_picture():
	# Randomizes the "seed" of which pics appear
	var picdata_copy = PictureData.list.keys()
	picdata_copy.shuffle()
	
	for x in picdata_copy:
		if Global.read("gallery_unlocked",x) == false && x not in Global.gamecont.pictures_current:
			Global.gamecont.pictures_current.append(x)
			return x
	
	### BUG!!! This can trigger still, I think when more than 1 pic is found.
	print("ALL IMAGES FOUND! Using random picture.")
	return PictureData.list.keys()[randi() % PictureData.list.size()] # Random picture

func init() -> void: ### THIS GETS EXECUTED BY RANDOMSPAWNS.GD
	pic_selected = select_picture()
	
	if PictureData.list[pic_selected].get("animated",false) == false:
		$SubViewport/Sprite2D.texture = load(PictureData.list[pic_selected]["path"])
		# Resize mesh depending on image size
		texture_width = float($SubViewport/Sprite2D.texture.get_width())
		texture_height = float($SubViewport/Sprite2D.texture.get_height())
	if PictureData.list[pic_selected].get("animated",false) == true:
		$SubViewport/Sprite2D.visible = false
		$SubViewport/AnimatedSprite2D.visible = true
		material_anim = PictureData.list[pic_selected]["path"]
		texture_width = PictureData.list[pic_selected]["width"]
		texture_height = PictureData.list[pic_selected]["height"]

	var formula = (texture_width / texture_height) - 1
	$MeshInstance3DFront.mesh.size.x += formula
	$MeshInstance3DBack.mesh.size.x += formula
	
	$SubViewport.size = Vector2(texture_width, texture_height)
	
func _process(_delta: float) -> void:
	if hovered && Input.is_action_just_pressed("Interact"):
		Global.save("gallery_unlocked",pic_selected,true)
		
		# Apply texture to spinning UI element
		var spinningpic = $"/root/Global/Player/UI/Collect/SubViewportContainer/SubViewport/SpinningPicture"
		spinningpic.width = texture_width
		spinningpic.height = texture_height
		if PictureData.list[pic_selected].get("animated",false) == false:
			spinningpic.texture = $SubViewport/Sprite2D.texture
			spinningpic.animated = false
		if PictureData.list[pic_selected].get("animated",false) == true:
			spinningpic.animated = true
			spinningpic.animation = material_anim
		
		Global.play_sound("paper_pickup")
		Global.gamecont.pages_collected += 1
		Global.page_counter_show( PictureData.list[pic_selected]["author"] )
		queue_free()

func _on_area_3d_area_entered(area: Area3D) -> void:
	if area.name == "PlayerGrab":
		hovered = true
		
func _on_area_3d_area_exited(area: Area3D) -> void:
	if area.name == "PlayerGrab":
		hovered = false
