extends Area2D



func _on_body_entered(body: Node2D) -> void:
	if(body.name == "Player"):
		body.set_movement_style(Player.MOVEMENT_STYLES.CLIMBING)

func _on_body_exited(body: Node2D) -> void:
	if(body.name == "Player"):
		body.set_movement_style(Player.MOVEMENT_STYLES.NORMAL)
