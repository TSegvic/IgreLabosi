extends AnimationPlayer

const HIPS := "HumanoidMesh/Hips"
const HEAD := "HumanoidMesh/Hips/HeadPivot"
const LS := "HumanoidMesh/Hips/LeftShoulder"
const RS := "HumanoidMesh/Hips/RightShoulder"
const LH := "HumanoidMesh/Hips/LeftHip"
const RH := "HumanoidMesh/Hips/RightHip"

const HIP_BASE_Y := 0.9


func _ready() -> void:
	_build_library()
	if has_animation("idle"):
		play("idle")


func _build_library() -> void:
	var lib := AnimationLibrary.new()
	lib.add_animation("idle", _make_idle())
	lib.add_animation("walk", _make_walk(0.7, deg_to_rad(28), deg_to_rad(32)))
	lib.add_animation("run", _make_walk(0.45, deg_to_rad(45), deg_to_rad(55)))
	lib.add_animation("jump", _make_jump())
	lib.add_animation("fall", _make_fall())
	lib.add_animation("attack", _make_attack())
	lib.add_animation("crouch_idle", _make_crouch_idle())
	add_animation_library("", lib)


func _make_idle() -> Animation:
	var anim := Animation.new()
	anim.length = 2.4
	anim.loop_mode = Animation.LOOP_LINEAR
	_track_v3(anim, HIPS + ":position", [
		[0.0, Vector3(0, HIP_BASE_Y, 0)],
		[1.2, Vector3(0, HIP_BASE_Y + 0.025, 0)],
		[2.4, Vector3(0, HIP_BASE_Y, 0)],
	])
	_track_v3(anim, HEAD + ":rotation", [
		[0.0, Vector3.ZERO],
		[1.2, Vector3(0, deg_to_rad(5), 0)],
		[2.4, Vector3.ZERO],
	])
	_track_v3(anim, LS + ":rotation", [[0.0, Vector3(0, 0, deg_to_rad(6))]])
	_track_v3(anim, RS + ":rotation", [[0.0, Vector3(0, 0, deg_to_rad(-6))]])
	_track_v3(anim, LH + ":rotation", [[0.0, Vector3.ZERO]])
	_track_v3(anim, RH + ":rotation", [[0.0, Vector3.ZERO]])
	return anim


func _make_walk(cycle: float, arm_swing: float, leg_swing: float) -> Animation:
	var anim := Animation.new()
	anim.length = cycle
	anim.loop_mode = Animation.LOOP_LINEAR
	var half := cycle * 0.5
	_track_v3(anim, LS + ":rotation", [
		[0.0, Vector3(arm_swing, 0, 0)],
		[half, Vector3(-arm_swing, 0, 0)],
		[cycle, Vector3(arm_swing, 0, 0)],
	])
	_track_v3(anim, RS + ":rotation", [
		[0.0, Vector3(-arm_swing, 0, 0)],
		[half, Vector3(arm_swing, 0, 0)],
		[cycle, Vector3(-arm_swing, 0, 0)],
	])
	_track_v3(anim, LH + ":rotation", [
		[0.0, Vector3(-leg_swing, 0, 0)],
		[half, Vector3(leg_swing, 0, 0)],
		[cycle, Vector3(-leg_swing, 0, 0)],
	])
	_track_v3(anim, RH + ":rotation", [
		[0.0, Vector3(leg_swing, 0, 0)],
		[half, Vector3(-leg_swing, 0, 0)],
		[cycle, Vector3(leg_swing, 0, 0)],
	])
	_track_v3(anim, HIPS + ":position", [
		[0.0, Vector3(0, HIP_BASE_Y - 0.02, 0)],
		[cycle * 0.25, Vector3(0, HIP_BASE_Y + 0.03, 0)],
		[half, Vector3(0, HIP_BASE_Y - 0.02, 0)],
		[cycle * 0.75, Vector3(0, HIP_BASE_Y + 0.03, 0)],
		[cycle, Vector3(0, HIP_BASE_Y - 0.02, 0)],
	])
	_method_track(anim, [cycle * 0.05, half + cycle * 0.05], "_on_footstep")
	return anim


func _make_jump() -> Animation:
	var anim := Animation.new()
	anim.length = 0.5
	anim.loop_mode = Animation.LOOP_NONE
	_track_v3(anim, LS + ":rotation", [
		[0.0, Vector3(0, 0, deg_to_rad(6))],
		[0.5, Vector3(deg_to_rad(-90), 0, deg_to_rad(15))],
	])
	_track_v3(anim, RS + ":rotation", [
		[0.0, Vector3(0, 0, deg_to_rad(-6))],
		[0.5, Vector3(deg_to_rad(-90), 0, deg_to_rad(-15))],
	])
	_track_v3(anim, LH + ":rotation", [
		[0.0, Vector3.ZERO],
		[0.5, Vector3(deg_to_rad(35), 0, 0)],
	])
	_track_v3(anim, RH + ":rotation", [
		[0.0, Vector3.ZERO],
		[0.5, Vector3(deg_to_rad(35), 0, 0)],
	])
	return anim


func _make_fall() -> Animation:
	var anim := Animation.new()
	anim.length = 0.8
	anim.loop_mode = Animation.LOOP_LINEAR
	_track_v3(anim, LS + ":rotation", [
		[0.0, Vector3(deg_to_rad(-30), 0, deg_to_rad(25))],
		[0.4, Vector3(deg_to_rad(-20), 0, deg_to_rad(30))],
		[0.8, Vector3(deg_to_rad(-30), 0, deg_to_rad(25))],
	])
	_track_v3(anim, RS + ":rotation", [
		[0.0, Vector3(deg_to_rad(-30), 0, deg_to_rad(-25))],
		[0.4, Vector3(deg_to_rad(-20), 0, deg_to_rad(-30))],
		[0.8, Vector3(deg_to_rad(-30), 0, deg_to_rad(-25))],
	])
	_track_v3(anim, LH + ":rotation", [[0.0, Vector3(deg_to_rad(15), 0, 0)]])
	_track_v3(anim, RH + ":rotation", [[0.0, Vector3(deg_to_rad(-15), 0, 0)]])
	return anim


func _make_attack() -> Animation:
	var anim := Animation.new()
	anim.length = 0.45
	anim.loop_mode = Animation.LOOP_NONE
	_track_v3(anim, RS + ":rotation", [
		[0.0, Vector3(0, 0, deg_to_rad(-6))],
		[0.1, Vector3(deg_to_rad(25), deg_to_rad(-25), 0)],
		[0.22, Vector3(deg_to_rad(-95), deg_to_rad(10), 0)],
		[0.45, Vector3(0, 0, deg_to_rad(-6))],
	])
	_track_v3(anim, LS + ":rotation", [
		[0.0, Vector3(0, 0, deg_to_rad(6))],
		[0.22, Vector3(deg_to_rad(-20), 0, deg_to_rad(10))],
		[0.45, Vector3(0, 0, deg_to_rad(6))],
	])
	_track_v3(anim, HIPS + ":rotation", [
		[0.0, Vector3.ZERO],
		[0.22, Vector3(0, deg_to_rad(-12), 0)],
		[0.45, Vector3.ZERO],
	])
	_method_track(anim, [0.22], "_on_attack_impact")
	return anim


func _make_crouch_idle() -> Animation:
	var anim := Animation.new()
	anim.length = 2.0
	anim.loop_mode = Animation.LOOP_LINEAR
	_track_v3(anim, LS + ":rotation", [[0.0, Vector3(deg_to_rad(-10), 0, deg_to_rad(12))]])
	_track_v3(anim, RS + ":rotation", [[0.0, Vector3(deg_to_rad(-10), 0, deg_to_rad(-12))]])
	_track_v3(anim, LH + ":rotation", [[0.0, Vector3(deg_to_rad(40), 0, 0)]])
	_track_v3(anim, RH + ":rotation", [[0.0, Vector3(deg_to_rad(40), 0, 0)]])
	_track_v3(anim, HIPS + ":position", [
		[0.0, Vector3(0, HIP_BASE_Y - 0.02, 0)],
		[1.0, Vector3(0, HIP_BASE_Y, 0)],
		[2.0, Vector3(0, HIP_BASE_Y - 0.02, 0)],
	])
	return anim


func _track_v3(anim: Animation, path: String, keys: Array) -> void:
	var idx := anim.add_track(Animation.TYPE_VALUE)
	anim.track_set_path(idx, path)
	anim.track_set_interpolation_type(idx, Animation.INTERPOLATION_LINEAR)
	for k in keys:
		anim.track_insert_key(idx, k[0], k[1])


func _method_track(anim: Animation, times: Array, method_name: String) -> void:
	var idx := anim.add_track(Animation.TYPE_METHOD)
	anim.track_set_path(idx, ".")
	for t in times:
		anim.track_insert_key(idx, t, {"method": method_name, "args": []})
