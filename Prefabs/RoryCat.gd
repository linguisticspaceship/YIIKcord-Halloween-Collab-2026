extends CharacterBody3D

var in_sight = false


var speed = 0
var speed_desired = 0
const spd_walk = 60 # Rory Cat will move at this speed when not being looked at
# How far away Rory Cat teleports from
var dist = 0
var dist_min = 2
var dist_max = 10
# So RoryCat isn't always directly behind player
var dist_rng = 0 
const dist_rng_min = 0
const dist_rng_max = 4

@onready var player = $"/root/Global/Player"
@onready var player_cam = $"/root/Global/Player/Camera3D"

func _on_visible_on_screen_notifier_3d_screen_entered() -> void:
	Global.play_sound("jumpscare")
	in_sight = true
	
func _on_visible_on_screen_notifier_3d_screen_exited() -> void:
	in_sight = false

func _process(delta: float) -> void:
	if in_sight:
		speed_desired = 0
	else:
		match Global.gamecont.pages_collected:
			0: 
				speed_desired = spd_walk
	
	if Input.is_action_pressed("Interact"):
		dist = randf_range(dist_min,dist_max)
		dist_rng = randf_range(dist_rng_min,dist_rng_max)
		var player_vector = player_cam.global_transform.origin + player_cam.global_transform.basis.x
		
		position = player_vector + Vector3(-dist,0,-dist) + Vector3(0,0,0)
		position.y = 0.9 # TODO: Make RoryCat snap to floor rather than do this manually.
		
func _physics_process(delta: float) -> void:
	if !in_sight:
		$MeshInstance3D.look_at(player.global_position, Vector3.UP, true)
		
		$NavigationAgent3D.target_position = player.global_position
		if !$NavigationAgent3D.is_target_reached():
			var nav_point_dir = to_local($NavigationAgent3D.get_next_path_position()).normalized()
			velocity = nav_point_dir * speed_desired * delta
			move_and_slide()


func _on_area_3d_killsphere_entered(area: Area3D) -> void:
	if area.name == "PlayerHitbox":
		print("GAME OVER!!!")
