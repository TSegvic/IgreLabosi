extends CharacterBody3D

@export var walk_speed: float = 4.5
@export var run_speed: float = 8.0
@export var crouch_speed: float = 2.0
@export var jump_velocity: float = 5.5
@export var acceleration: float = 12.0
@export var mouse_sensitivity: float = 0.0025

@export var stamina_max: float = 100.0
@export var stamina_drain_rate: float = 25.0
@export var stamina_regen_rate: float = 18.0
@export var stamina_resume_threshold: float = 25.0

enum State { IDLE, WALK, RUN, CROUCH, JUMP, FALL }

const STAND_HEIGHT: float = 1.8
const CROUCH_HEIGHT: float = 1.0
const STAND_EYE_Y: float = 1.65
const CROUCH_EYE_Y: float = 0.85

var current_state: State = State.IDLE
var stamina: float = 100.0
var can_run: bool = true
var is_crouching: bool = false
var was_on_floor: bool = true
var is_attacking: bool = false
var fall_speed_at_land: float = 0.0

@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var humanoid: Node3D = $HumanoidMesh
@onready var camera_rig: Node3D = $CameraRig
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var state_label: Label = $HUD/StateLabel
@onready var stamina_bar: ProgressBar = $HUD/StaminaBar
@onready var view_label: Label = $HUD/ViewLabel

@onready var sfx_footstep: AudioStreamPlayer3D = $SFX/Footstep
@onready var sfx_jump: AudioStreamPlayer3D = $SFX/Jump
@onready var sfx_land: AudioStreamPlayer3D = $SFX/Land
@onready var sfx_attack: AudioStreamPlayer3D = $SFX/Attack

@onready var vfx_land_dust: GPUParticles3D = $VFX/LandDust
@onready var vfx_muzzle_fps: GPUParticles3D = $CameraRig/PitchNode/SpringArm3D/Camera3D/FPSWeapon/MuzzleFlash
@onready var vfx_muzzle_tps: GPUParticles3D = $HumanoidMesh/Hips/RightShoulder/Weapon/MuzzleFlash


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	stamina = stamina_max
	_load_sound_files()
	_setup_particles()
	if animation_player and not animation_player.animation_finished.is_connected(_on_animation_finished):
		animation_player.animation_finished.connect(_on_animation_finished)


func _load_sound_files() -> void:
	# Streams are assigned only when the user has placed the .ogg/.wav files in res://sounds/
	_try_load_stream(sfx_footstep, ["res://sounds/footstep.ogg", "res://sounds/footstep.wav"])
	_try_load_stream(sfx_jump, ["res://sounds/jump.ogg", "res://sounds/jump.wav"])
	_try_load_stream(sfx_land, ["res://sounds/land.ogg", "res://sounds/land.wav"])
	_try_load_stream(sfx_attack, ["res://sounds/attack.ogg", "res://sounds/attack.wav"])


func _try_load_stream(node: AudioStreamPlayer3D, paths: Array) -> void:
	if node == null:
		return
	for p in paths:
		if ResourceLoader.exists(p):
			node.stream = load(p)
			return


func _setup_particles() -> void:
	if vfx_land_dust:
		_configure_dust(vfx_land_dust)
	if vfx_muzzle_fps:
		_configure_muzzle(vfx_muzzle_fps)
	if vfx_muzzle_tps:
		_configure_muzzle(vfx_muzzle_tps)


func _configure_dust(p: GPUParticles3D) -> void:
	var mat := ParticleProcessMaterial.new()
	mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	mat.emission_sphere_radius = 0.2
	mat.direction = Vector3(0, 1, 0)
	mat.spread = 75.0
	mat.initial_velocity_min = 1.2
	mat.initial_velocity_max = 2.4
	mat.gravity = Vector3(0, -1.5, 0)
	mat.damping_min = 1.0
	mat.damping_max = 1.5
	mat.scale_min = 0.25
	mat.scale_max = 0.5
	var grad := Gradient.new()
	grad.set_color(0, Color(0.85, 0.8, 0.7, 0.9))
	grad.add_point(0.4, Color(0.78, 0.73, 0.62, 0.7))
	grad.set_color(1, Color(0.6, 0.55, 0.45, 0.0))
	var gtex := GradientTexture1D.new()
	gtex.gradient = grad
	mat.color_ramp = gtex
	p.process_material = mat
	p.draw_pass_1 = _make_particle_quad()
	p.amount = 28
	p.lifetime = 0.7
	p.one_shot = true
	p.explosiveness = 0.95
	p.emitting = false


func _configure_muzzle(p: GPUParticles3D) -> void:
	var mat := ParticleProcessMaterial.new()
	mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_POINT
	mat.direction = Vector3(0, 0, -1)
	mat.spread = 30.0
	mat.initial_velocity_min = 1.5
	mat.initial_velocity_max = 3.5
	mat.gravity = Vector3.ZERO
	mat.scale_min = 0.15
	mat.scale_max = 0.4
	var grad := Gradient.new()
	grad.set_color(0, Color(1.0, 0.95, 0.6, 1.0))
	grad.add_point(0.3, Color(1.0, 0.7, 0.2, 0.9))
	grad.set_color(1, Color(0.8, 0.2, 0.0, 0.0))
	var gtex := GradientTexture1D.new()
	gtex.gradient = grad
	mat.color_ramp = gtex
	p.process_material = mat
	p.draw_pass_1 = _make_particle_quad()
	p.amount = 14
	p.lifetime = 0.18
	p.one_shot = true
	p.explosiveness = 1.0
	p.emitting = false


func _make_particle_quad() -> QuadMesh:
	var q := QuadMesh.new()
	q.size = Vector2(0.35, 0.35)
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	m.vertex_color_use_as_albedo = true
	m.albedo_color = Color(1, 1, 1, 1)
	q.material = m
	return q


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event.is_action_pressed("attack") and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_start_attack()


func _start_attack() -> void:
	if is_attacking or animation_player == null:
		return
	if not animation_player.has_animation("attack"):
		return
	is_attacking = true
	animation_player.stop()
	animation_player.play("attack")


func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "attack":
		is_attacking = false
		_update_animation_state(true)


# Called from AnimationPlayer method tracks during walk/run cycles
func _on_footstep() -> void:
	if not is_on_floor():
		return
	if sfx_footstep and sfx_footstep.stream:
		sfx_footstep.pitch_scale = randf_range(0.92, 1.08)
		sfx_footstep.play()


# Called from AnimationPlayer method track at the punch impact moment
func _on_attack_impact() -> void:
	if sfx_attack and sfx_attack.stream:
		sfx_attack.play()
	if camera_rig and camera_rig.is_fps:
		if vfx_muzzle_fps:
			vfx_muzzle_fps.restart()
	else:
		if vfx_muzzle_tps:
			vfx_muzzle_tps.restart()


func _physics_process(delta: float) -> void:
	var input_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)).normalized()

	_handle_crouch()

	var moving_forward := input_dir.y < -0.1
	var wants_run := Input.is_action_pressed("run") and not is_crouching and moving_forward
	var running := wants_run and can_run

	var speed: float = walk_speed
	if is_crouching:
		speed = crouch_speed
	elif running:
		speed = run_speed

	if running:
		stamina = max(stamina - stamina_drain_rate * delta, 0.0)
		if stamina <= 0.0:
			can_run = false
	else:
		stamina = min(stamina + stamina_regen_rate * delta, stamina_max)
		if not can_run and stamina >= stamina_resume_threshold:
			can_run = true

	if not is_on_floor():
		velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity") * delta
		fall_speed_at_land = velocity.y

	if Input.is_action_just_pressed("jump") and is_on_floor() and not is_crouching:
		velocity.y = jump_velocity
		if sfx_jump and sfx_jump.stream:
			sfx_jump.play()

	var target_h := Vector3(direction.x * speed, 0.0, direction.z * speed)
	velocity.x = move_toward(velocity.x, target_h.x, acceleration * delta * speed)
	velocity.z = move_toward(velocity.z, target_h.z, acceleration * delta * speed)

	move_and_slide()
	_update_state(input_dir, running)
	_update_animation_state(false)
	_check_landing()
	_update_hud()
	was_on_floor = is_on_floor()


func _check_landing() -> void:
	if not was_on_floor and is_on_floor():
		if sfx_land and sfx_land.stream and fall_speed_at_land < -2.0:
			sfx_land.play()
		if vfx_land_dust and fall_speed_at_land < -1.5:
			vfx_land_dust.restart()


func _handle_crouch() -> void:
	var want_crouch: bool = Input.is_action_pressed("crouch")
	if want_crouch and not is_crouching:
		_set_crouch(true)
	elif not want_crouch and is_crouching:
		if not _ceiling_above():
			_set_crouch(false)


func _set_crouch(crouch: bool) -> void:
	is_crouching = crouch
	var shape: CapsuleShape3D = collision_shape.shape
	if crouch:
		shape.height = CROUCH_HEIGHT
		collision_shape.position.y = CROUCH_HEIGHT * 0.5
		humanoid.scale = Vector3(1.0, CROUCH_HEIGHT / STAND_HEIGHT, 1.0)
		camera_rig.position.y = CROUCH_EYE_Y
	else:
		shape.height = STAND_HEIGHT
		collision_shape.position.y = STAND_HEIGHT * 0.5
		humanoid.scale = Vector3.ONE
		camera_rig.position.y = STAND_EYE_Y


func _ceiling_above() -> bool:
	var space_state := get_world_3d().direct_space_state
	var from: Vector3 = global_position + Vector3(0.0, CROUCH_HEIGHT, 0.0)
	var to: Vector3 = global_position + Vector3(0.0, STAND_HEIGHT + 0.05, 0.0)
	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [self.get_rid()]
	var result := space_state.intersect_ray(query)
	return not result.is_empty()


func _update_state(input_dir: Vector2, running: bool) -> void:
	if not is_on_floor():
		if velocity.y > 0.05:
			current_state = State.JUMP
		else:
			current_state = State.FALL
	elif is_crouching:
		current_state = State.CROUCH
	elif input_dir.length() > 0.1:
		current_state = State.RUN if running else State.WALK
	else:
		current_state = State.IDLE


func _update_animation_state(force: bool) -> void:
	if is_attacking or animation_player == null:
		return
	var anim_name := ""
	match current_state:
		State.IDLE:
			anim_name = "idle"
		State.WALK:
			anim_name = "walk"
		State.RUN:
			anim_name = "run"
		State.JUMP:
			anim_name = "jump"
		State.FALL:
			anim_name = "fall"
		State.CROUCH:
			anim_name = "crouch_idle"
	if anim_name == "":
		return
	if not animation_player.has_animation(anim_name):
		return
	if force or animation_player.current_animation != anim_name:
		animation_player.play(anim_name)


func _update_hud() -> void:
	if state_label:
		state_label.text = "State: %s" % State.keys()[current_state]
	if stamina_bar:
		stamina_bar.value = stamina
	if view_label and camera_rig:
		view_label.text = "View: %s" % ("FPS" if camera_rig.is_fps else "TPS")
