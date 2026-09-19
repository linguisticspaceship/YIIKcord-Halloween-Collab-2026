extends RigidBody3D

var in_sight = false



# How far away Rory Cat teleports from
var dist = 0
var dist_min = 2
var dist_max = 10
# So RoryCat isn't always directly behind player
var dist_rng = 0 
const dist_rng_min = 0
const dist_rng_max = 4

@onready var player = $"../Player"

func _on_visible_on_screen_notifier_3d_screen_entered() -> void:
	Global.play_sound("jumpscare")
	in_sight = true
	

func _on_visible_on_screen_notifier_3d_screen_exited() -> void:
	in_sight = false

func _process(delta: float) -> void:
	if Input.is_action_pressed("Interact"):
		dist = randf_range(dist_min,dist_max)
		dist_rng = randf_range(dist_rng_min,dist_rng_max)
		position = Vector3((player.position.x + dist + dist_rng) * sign(player.rotation.y), 0, 0)
	print(player.rotation)
