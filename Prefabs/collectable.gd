extends Node3D

@onready var material = $SubViewport/Sprite2D.texture
@onready var material_anim = $SubViewport/AnimatedSprite2D.animation

@export var manual = false # If manually placed, not random.
@export var video = false

var hovered = false # If mouse on me.

var pic_selected = ""

var texture_width
var texture_height

func _ready() -> void:
	# HARDCODED.
	if manual and video:
		if Global.read("gallery_unlocked","chenichii_1",false) == true:
			queue_free()
		pic_selected = "chenichii_1"
		$MeshInstance3DFront.visible = false
		$MeshInstance3DBack.visible = false
		$TAPE.visible = true
		return

# Find random picture to use
func select_picture():
	# Randomizes the "seed" of which pics appear
	var picdata_copy = PictureData.list.keys()
	
	picdata_copy.erase("chenichii_1") # SPECIAL: This is manually placed only.
	
	picdata_copy.shuffle()
	
	for x in picdata_copy:
		if Global.read("gallery_unlocked",x) == true:
			picdata_copy.erase(x)
	
	for x in picdata_copy:
		if picdata_copy.size() != 0:
			if Global.read("gallery_unlocked",x) == false && x not in Global.gamecont.pictures_current:
				Global.gamecont.pictures_current.append(x)
				picdata_copy.erase(x)
				return x
		
		if picdata_copy.size() == 0:
			print("ALL IMAGES FOUND! Using random picture.")
			return PictureData.list.keys()[randi() % PictureData.list.size()] # Random picture
	
	### BUG!!! This can trigger still, I think when more than 1 pic is found.
	print("ALL IMAGES FOUND! Using random picture.")
	return picdata_copy[ randi() % picdata_copy.size() ]
	### OLD: return PictureData.list.keys()[randi() % PictureData.list.size()] # Random picture

func init() -> void: ### THIS GETS EXECUTED BY RANDOMSPAWNS.GD
	if manual:
		return
		
	pic_selected = select_picture()
	
	if PictureData.list[pic_selected].get("animated",false) == false:
		$SubViewport/Sprite2D.texture = load(PictureData.list[pic_selected].get("path","res://Sprites/Fanart/Null.png"))
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
		Global.save("gallery_unlocked", pic_selected, true)
		Global.play_sound("paper_pickup")
		
		if !video:
			page_pickup()
		if video:
			special_pickup("You found a tape!\nYou added it to your collection.")

		queue_free()
	
	
func page_pickup():
	$"/root/Global/Player/UI/Collect/PageCounter".visible = true
	$"/root/Global/Player/UI/Collect/SubViewportContainer/SubViewport/SpinningPicture".visible = true
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
	
	Global.gamecont.pages_collected += 1
	
	var extra_text = ""
	
	if PictureData.list[pic_selected].get("writing",false):
		extra_text = "\n(Check the gallery to read!)"
	
	Global.page_counter_show( PictureData.list[pic_selected]["author"] + extra_text )

func special_pickup(text):
	$"/root/Global/Player/UI/Collect/PageCounter".visible = false
	$"/root/Global/Player/UI/Collect/SubViewportContainer/SubViewport/SpinningPicture".visible = false
	Global.page_counter_show( text )

func _on_area_3d_area_entered(area: Area3D) -> void:
	if area.name == "PlayerGrab":
		hovered = true
		
func _on_area_3d_area_exited(area: Area3D) -> void:
	if area.name == "PlayerGrab":
		hovered = false
