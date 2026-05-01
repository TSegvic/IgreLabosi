extends Area2D

@export var damage: int = 5
@export var respawn_delay: float = 2.0
signal hit(value: int)

@onready var shape: CollisionShape2D = $CollisionShape2D
@onready var polygon: Polygon2D = $Polygon2D

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		hit.emit(damage)
		polygon.visible = false
		shape.set_deferred("disabled", true)
		await get_tree().create_timer(respawn_delay).timeout
		polygon.visible = true
		shape.set_deferred("disabled", false)
