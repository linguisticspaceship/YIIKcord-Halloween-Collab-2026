extends CharacterBody3D

var speed = 0 # Current speed
const speed_walk = 5
const speed_sprint = 7
var sprinting = false
const fall_acceleration = 30

var mouse_sensitivity = 0.01
enum { MOUSE_IDLE, MOUSE_HOVER }
var mouse_state = MOUSE_IDLE

var alive = true
var godmode = false # DEBUG

var SpawnScript : Node

var gameover_timer = 0.0
const gameover_timer_goal = 2.0

# Mobile
var look_stick_pressed = false

func _process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity.y = velocity.y - (fall_acceleration * delta)
	
	if alive:
		movement_pos()
	pointer_change()
	
	if !alive:
		gameover_timer = move_toward(gameover_timer, gameover_timer_goal, get_process_delta_time())
	
		if gameover_timer >= gameover_timer_goal:
			set_static(0.0)
			get_tree().change_scene_to_file("res://Scenes/GameOverCutscene.tscn")
			alive = true
			Global.gamecont.reset()
			Global.player_disable()

func set_static(opacity=0.0):
	if godmode:
		return
	
	opacity = clamp(opacity, 0.0, 0.3)
	$UI/Static.set_modulate( Color(1.0, 1.0, 1.0, opacity) )
	
func kill_me(): # Executed by RoryCat object
	if godmode:
		print("Prevented death!")
		return

	alive = false
	speed = 0
	look_at_rorycat(40)
		
func look_at_rorycat(strength=40):
	var rory_cat = get_node("/root/TestArea/RoryCat")
	#look_at(Vector3(rory_cat.position.x, rory_cat.position.y, rory_cat.position.z))

	var trans = transform.looking_at( rory_cat.transform.origin, Vector3.UP )
	self.transform = self.transform.interpolate_with(trans, strength * get_process_delta_time())
	
func _input(event: InputEvent) -> void:
	
	if !Global.mobile:
		if (Input.mouse_mode != Input.MOUSE_MODE_CAPTURED) and event is InputEventMouseButton: 
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if Global.mobile:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	movement_rot(event)
	
func movement_pos():
	if Input.is_action_pressed("Sprint"):
		speed = speed_sprint
		sprinting = true
	else:
		speed = speed_walk
		sprinting = false
	
	var input_dir = Input.get_vector("MoveLeft", "MoveRight", "MoveForward", "MoveBackward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized() # EXPERIMENT: remove normalized

	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		footstep_sfx()
	else: # Slow down to 0
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed) 

	move_and_slide()
	# Wall collision
	#for i in get_slide_collision_count():
	#	var collision = get_slide_collision(i)
	
func movement_rot(event: InputEvent):
	if !Global.mobile:
		if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
			return
			
	if Global.mobile:
		if !look_stick_pressed:
			return
	
	if event is InputEventMouseMotion || event is InputEventScreenDrag:
		var mouse_sensitivity_multiplier = 0
		if event is InputEventScreenDrag:
			mouse_sensitivity_multiplier = 0.05
		
		# Horizontal
		rotate_y(-event.relative.x * (mouse_sensitivity * mouse_sensitivity_multiplier))
		# Vertical
		$Camera3D.rotate_x(-event.relative.y * (mouse_sensitivity * mouse_sensitivity_multiplier))
		var vertical_max = 55
		$Camera3D.rotation.x = clampf($Camera3D.rotation.x, -deg_to_rad(vertical_max), deg_to_rad(vertical_max))
		
func footstep_sfx():
	#var chance = 20 # Amount of numbers to be drawn in RNG
	const timer_walk = 0.7 # Seconds before allowed to play SFX again
	const timer_sprint = 0.3 # Ditto
	
	if !sprinting:
		$FootstepSFXTimer.wait_time = timer_walk
	if sprinting:
		$FootstepSFXTimer.wait_time = timer_sprint

	if $FootstepSFXTimer.is_stopped():		
		$FootstepSFXTimer.start()
		Global.play_sound("footstep_dirt")
	
func pointer_change():
	match mouse_state:
		MOUSE_IDLE:
			$UI/Container/Pointer.texture = load("res://Sprites/Cursor.png")
		MOUSE_HOVER:
			$UI/Container/Pointer.texture = load("res://Sprites/Cursor Hover.png")

func _on_player_grab_area_entered(area: Area3D) -> void:
	if area.get_parent().is_in_group("Collectable"):
		mouse_state = MOUSE_HOVER
		area.get_parent().get_node("AnimationPlayer").play("Pulse")

func _on_player_grab_area_exited(area: Area3D) -> void:
	if area.get_parent().is_in_group("Collectable"):
		mouse_state = MOUSE_IDLE
		area.get_parent().get_node("AnimationPlayer").play("RESET")


func _on_pagecounter_timer_timeout() -> void:
	$UI/Collect/AnimationPlayer.play("Hide")
	$UI/Collect/Timer.stop()


func _on_joystick_look_pressed() -> void:
	look_stick_pressed = true

func _on_joystick_look_released(input_vector: Vector2) -> void:
	look_stick_pressed = false
