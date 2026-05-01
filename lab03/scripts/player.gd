extends RigidBody2D

@export var move_speed: float = 250.0
var speed_multiplier: float = 1.0

func _physics_process(_delta: float) -> void:
	var dir := Vector2(
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up", "ui_down")
	)
	if dir.length() > 0.0:
		dir = dir.normalized()
	linear_velocity = dir * move_speed * speed_multiplier

func set_speed_multiplier(value: float) -> void:
	speed_multiplier = value
