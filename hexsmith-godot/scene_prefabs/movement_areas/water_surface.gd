## The top level of a body of water. Allows the player to swim up to a maximum height.

extends Area2D

@onready var max_height: Marker2D = $max_height

func _on_body_entered(body: Node2D) -> void:
	if(body is Player):
		body.movement_state_machine.change_state(body.movement_state_machine.current_state, "swim")
		body.movement_state_machine.current_state.max_height = max_height.global_position.y
