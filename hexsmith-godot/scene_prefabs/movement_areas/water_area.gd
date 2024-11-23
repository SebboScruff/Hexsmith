# Used for monitoring when the player enters and exits a patch of water.
# All relevant in-game changes are done through player_controller - this is just
# a signal manager.
# This node is set up in a particular way to allow the moving agents to
# situationally walk on the surface of the water. The surface is a 1-way collider
# on a different collision layer.
extends Node2D

# Modify the player's movement state based on whether they are within
# the Underwater Area or not.
# TODO Probably needs to be slightly more safe than just a direct name check
func _on_underwater_area_body_entered(body: Node2D) -> void:
	if(body.name == "Player"):
		body.set_movement_style(Player.MOVEMENT_STYLES.SWIMMING)


func _on_underwater_area_body_exited(body: Node2D) -> void:
	if(body.name == "Player"):
		body.set_movement_style(Player.MOVEMENT_STYLES.NORMAL)
