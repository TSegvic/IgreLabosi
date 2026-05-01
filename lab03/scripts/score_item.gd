extends Area2D

@export var points: int = 10
signal collected(value: int)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		collected.emit(points)
		queue_free()
