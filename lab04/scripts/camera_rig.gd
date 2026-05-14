extends Node3D

@export var mouse_sensitivity: float = 0.0025
@export var pitch_min_deg: float = -60.0
@export var pitch_max_deg: float = 60.0

@export_group("TPS")
@export var tps_arm_length: float = 4.0
@export var tps_shoulder_offset: float = 0.7
@export var tps_height_offset: float = 0.4
@export var tps_smooth_speed: float = 10.0

var is_fps: bool = true
var pitch: float = 0.0

@onready var pitch_node: Node3D = $PitchNode
@onready var spring_arm: SpringArm3D = $PitchNode/SpringArm3D
@onready var camera: Camera3D = $PitchNode/SpringArm3D/Camera3D
@onready var fps_weapon: Node3D = $PitchNode/SpringArm3D/Camera3D/FPSWeapon
@onready var player: Node3D = get_parent()
@onready var player_mesh: Node3D = player.get_node_or_null("HumanoidMesh")


func _ready() -> void:
	_apply_mode_immediate()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		pitch -= event.relative.y * mouse_sensitivity
		pitch = clamp(pitch, deg_to_rad(pitch_min_deg), deg_to_rad(pitch_max_deg))
		pitch_node.rotation.x = pitch
	if event.is_action_pressed("toggle_view"):
		is_fps = not is_fps
		_update_visibility()


func _physics_process(delta: float) -> void:
	var target_length: float = 0.0 if is_fps else tps_arm_length
	var target_offset: Vector3 = Vector3.ZERO if is_fps else Vector3(tps_shoulder_offset, tps_height_offset, 0.0)
	spring_arm.spring_length = lerp(spring_arm.spring_length, target_length, clamp(delta * tps_smooth_speed, 0.0, 1.0))
	spring_arm.position = spring_arm.position.lerp(target_offset, clamp(delta * tps_smooth_speed, 0.0, 1.0))


func _apply_mode_immediate() -> void:
	if is_fps:
		spring_arm.spring_length = 0.0
		spring_arm.position = Vector3.ZERO
	else:
		spring_arm.spring_length = tps_arm_length
		spring_arm.position = Vector3(tps_shoulder_offset, tps_height_offset, 0.0)
	_update_visibility()


func _update_visibility() -> void:
	if fps_weapon:
		fps_weapon.visible = is_fps
	if player_mesh:
		player_mesh.visible = not is_fps
