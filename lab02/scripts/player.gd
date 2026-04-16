extends CharacterBody3D

# Movement
@export var walk_speed: float = 4.5
@export var run_speed: float = 8.0
@export var crouch_speed: float = 2.0
@export var jump_velocity: float = 5.5
@export var acceleration: float = 12.0
@export var mouse_sensitivity: float = 0.0025

# Stamina
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

@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var player_mesh: MeshInstance3D = $PlayerMesh
@onready var camera_rig: Node3D = $CameraRig
@onready var state_label: Label = $HUD/StateLabel
@onready var stamina_bar: ProgressBar = $HUD/StaminaBar
@onready var view_label: Label = $HUD/ViewLabel


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	stamina = stamina_max


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


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

	if Input.is_action_just_pressed("jump") and is_on_floor() and not is_crouching:
		velocity.y = jump_velocity

	var target_h := Vector3(direction.x * speed, 0.0, direction.z * speed)
	velocity.x = move_toward(velocity.x, target_h.x, acceleration * delta * speed)
	velocity.z = move_toward(velocity.z, target_h.z, acceleration * delta * speed)

	move_and_slide()
	_update_state(input_dir, running)
	_update_hud()


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
		player_mesh.scale = Vector3(1.0, CROUCH_HEIGHT / STAND_HEIGHT, 1.0)
		player_mesh.position.y = CROUCH_HEIGHT * 0.5
		camera_rig.position.y = CROUCH_EYE_Y
	else:
		shape.height = STAND_HEIGHT
		collision_shape.position.y = STAND_HEIGHT * 0.5
		player_mesh.scale = Vector3.ONE
		player_mesh.position.y = STAND_HEIGHT * 0.5
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


func _update_hud() -> void:
	if state_label:
		state_label.text = "State: %s" % State.keys()[current_state]
	if stamina_bar:
		stamina_bar.value = stamina
	if view_label and camera_rig:
		view_label.text = "View: %s" % ("FPS" if camera_rig.is_fps else "TPS")
