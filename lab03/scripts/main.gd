extends Node2D

@export var layout_open_duration: float = 4.0
@export var tween_time: float = 0.4

var score: int = 0
var layout_busy: bool = false

@onready var score_label: Label = $UI/ScoreLabel
@onready var hint_label: Label = $UI/HintLabel
@onready var speed_label: Label = $UI/SpeedLabel
@onready var movable_wall_1: StaticBody2D = $MovableWall1
@onready var movable_wall_2: StaticBody2D = $MovableWall2
@onready var player: RigidBody2D = $Player

var wall1_closed: Vector2
var wall2_closed: Vector2
var wall1_open: Vector2
var wall2_open: Vector2

func _ready() -> void:
	wall1_closed = movable_wall_1.position
	wall2_closed = movable_wall_2.position
	wall1_open = wall1_closed + Vector2(0, -130)
	wall2_open = wall2_closed + Vector2(0, 130)

	for item in get_tree().get_nodes_in_group("score_items"):
		if item.has_signal("collected"):
			item.collected.connect(_on_score_collected)
	for item in get_tree().get_nodes_in_group("damage_items"):
		if item.has_signal("hit"):
			item.hit.connect(_on_damage_hit)

	_update_score()
	hint_label.text = "Press SPACE to open passages"

func _process(_delta: float) -> void:
	speed_label.text = "Speed: x%.1f" % player.speed_multiplier

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") and not layout_busy:
		_change_layout()

func _on_score_collected(value: int) -> void:
	score += value
	_update_score()

func _on_damage_hit(value: int) -> void:
	score = max(0, score - value)
	_update_score()

func _update_score() -> void:
	score_label.text = "Score: %d" % score

func _change_layout() -> void:
	layout_busy = true
	hint_label.text = "Passages OPEN. Reverting soon..."

	var t1 := create_tween().set_parallel(true)
	t1.tween_property(movable_wall_1, "position", wall1_open, tween_time)
	t1.tween_property(movable_wall_2, "position", wall2_open, tween_time)
	await t1.finished

	await get_tree().create_timer(layout_open_duration).timeout

	hint_label.text = "Passages closing..."
	var t2 := create_tween().set_parallel(true)
	t2.tween_property(movable_wall_1, "position", wall1_closed, tween_time)
	t2.tween_property(movable_wall_2, "position", wall2_closed, tween_time)
	await t2.finished

	layout_busy = false
	hint_label.text = "Press SPACE to open passages"
