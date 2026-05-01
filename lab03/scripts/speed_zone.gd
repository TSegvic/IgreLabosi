extends Area2D

@export var multiplier: float = 1.8

@onready var polygon: Polygon2D = $Polygon2D

func _ready() -> void:
	if multiplier >= 2.0:
		polygon.color = Color(0.55, 0.25, 0.95, 0.45)
	else:
		polygon.color = Color(0.2, 0.85, 0.4, 0.45)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.set_speed_multiplier(multiplier)

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.set_speed_multiplier(1.0)
