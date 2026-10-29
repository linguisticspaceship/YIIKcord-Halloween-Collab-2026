extends Node3D

@export var scene = ""
@export var quit = false
@export var displaytext = ""
@export var displaytext_size = 90

var hovered = false

var button_prefab = load("res://Prefabs/button_ui.tscn") # Hacky

func _ready() -> void:
	$Grave/Label3D.text = displaytext
	$Grave/Label3D.font_size = displaytext_size

func _process(_delta: float) -> void:
	if hovered:
		$Grave/Label3D.modulate = "FF0000"
	else:
		$Grave/Label3D.modulate = "FFFFFF"

func _on_area_3d_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if quit:
			get_tree().quit()
		
		var instance = button_prefab.instantiate()
		if scene != "":
			instance.SceneGoto = scene
		add_child(instance)
		instance._on_pressed()

func _on_area_3d_mouse_entered() -> void:
	hovered = true
	
func _on_area_3d_mouse_exited() -> void:
	hovered = false
