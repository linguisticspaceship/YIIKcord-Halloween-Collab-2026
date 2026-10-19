extends CharacterBody3D

var active = false # If he is in field or not

# Rory Cat will spawn in, then when not stared at for a while will despawn. Then respawn later.
var despawn_timer = 0
var despawn_goal = 5 # Seconds before despawn
var respawn_timer = 0
var respawn_goal = 5 # Seconds before respawn

var in_sight = false

var stare_meter = 0
var stare_max = 5 # How many seconds before GAME OVER!

# When not in sight, slowly moves towards player.
var speed = 0
var speed_desired = 0
const spd_walk = 1.999 # This increases as page count increases
# How far away Rory Cat teleports from
var dist = 0
var dist_min = 4
var dist_max = 12

@onready var player = $"/root/Global/Player"
@onready var player_cam = $"/root/Global/Player/Camera3D"

func _on_visible_on_screen_notifier_3d_screen_entered() -> void:
	Global.play_sound("jumpscare")
	in_sight = true
	
func _on_visible_on_screen_notifier_3d_screen_exited() -> void:
	in_sight = false

func staring_mechanics():
	
	#print(stare_meter)
	
	player.set_static( (stare_meter - 0.5) / 4 ) # Subtracting makes it take longer for static to appear, divide is just to make the motion more smooth

	if in_sight:
		speed_desired = 0
		despawn_timer = 0
		stare_meter = move_toward(stare_meter, stare_max, get_process_delta_time())
	if not in_sight:
		var page_percent = float(Global.gamecont.pages_collected) / float(Global.gamecont.page_goal) * 100
		# 60 is a slow speed.
		speed_desired = spd_walk * page_percent # As pages go up, faster we go.
		#print(speed_desired)
		stare_meter = move_toward(stare_meter, 0, get_process_delta_time())
		
		
	if stare_meter >= stare_max:
		player.kill_me()

func spawn():
	dist = randf_range(dist_min,dist_max)
		
	var angle = player.rotation.y + 180 # 180 offset makes it so that rorycat teleports (mostly) behind
	position = player.position + Vector3(cos(angle), 0, -sin(angle)) * dist
	position.y = 0.9 # TODO: Make RoryCat snap to floor rather than do this manually.
	
func spawn_and_despawn_timer():
	var delta = get_process_delta_time()
	
	if active:
		visible = true
		$Collision.disabled = false
		$Area3D.monitoring = true
		despawn_timer = move_toward(despawn_timer, despawn_goal, delta)
		if despawn_timer >= despawn_goal:
			respawn_timer = 0
			despawn_timer = 0
			active = false
		
	if !active:
		visible = false
		$Collision.disabled = true
		$Area3D.monitoring = false
		respawn_timer = move_toward(respawn_timer, respawn_goal, delta)
		if respawn_timer >= respawn_goal:
			active = true
			respawn_timer = 0
			despawn_timer = 0
			spawn()

func _process(delta: float) -> void:
	# Debug
	Global.debug_respawntime = respawn_timer
	Global.debug_despawntime = despawn_timer
	Global.debug_roryactive = active
	
	# Inactive until page 1
	if Global.gamecont.pages_collected == 0:
		despawn_timer = 0
		respawn_timer = 0
		active = false
		$Collision.disabled = true
		$Area3D.monitoring = false
		#return
	
	spawn_and_despawn_timer()

	staring_mechanics()
		
func _physics_process(delta: float) -> void:
	$MeshInstance3D.look_at(player.global_position, Vector3.UP, true)
	# Prevents from looking up or down
	$MeshInstance3D.rotation.x = 0
	
	if !in_sight:
		#$MeshInstance3D.look_at(player.global_position, Vector3.UP, true)
		
		$NavigationAgent3D.target_position = player.global_position
		if !$NavigationAgent3D.is_target_reached():
			var nav_point_dir = to_local($NavigationAgent3D.get_next_path_position()).normalized()
			velocity = nav_point_dir * speed_desired * delta
			move_and_slide()


var touched_player = false
func _on_area_3d_killsphere_entered(area: Area3D) -> void:
	if area.name == "PlayerHitbox" && !touched_player:
		print("I TOUCHED PLAYER!")
		touched_player = true
		player.kill_me()
