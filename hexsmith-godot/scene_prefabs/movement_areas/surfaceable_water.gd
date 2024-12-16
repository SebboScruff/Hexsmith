## Area Behaviours for the shoreline of any water surfaces, where it possible for the player to jump
## out.
extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if(body is Player):
		body.movement_state_machine.change_state(body.movement_state_machine.current_state, "water exit")

func _on_body_exited(body: Node2D) -> void:
	if(body is Player):
		body.movement_state_machine.change_state(body.movement_state_machine.current_state, "swim")
