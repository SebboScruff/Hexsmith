## Area Behaviours for the shoreline of any water surfaces, where it possible for the player to jump
## out.
extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if(body is Player):
		body.state_machine_runner.change_state(body.state_machine_runner.current_state, "water exit")

func _on_body_exited(body: Node2D) -> void:
	if(body is Player):
		body.state_machine_runner.change_state(body.state_machine_runner.current_state, "swim")
