# Used for monitoring when the player enters and exits a patch of water.
# All relevant in-game changes are done through player_controller - this is just
# a signal manager.

# Water Zone Node Tree Explanation:
# - water_surface (StaticBody2D) is the hard one-way collider that allows agents to move on
# the water's surface - for example, the player with Aqua Strider. Collision Layer = 6

# - underwater_area (Area2D) is the whole area that transitions the player into the 
# SWIMMING movement style. Collision Layer = 5

# - surfaceable_region (Area2D) is the very top of the Underwater Region, and switches
# a bool that allows the player to jump and exit the water. Collision Layer = 5

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

# ---

func _on_surfaceable_region_body_entered(body: Node2D) -> void:
	if(body.name == "Player"):
		body.can_surface = true

func _on_surfaceable_region_body_exited(body: Node2D) -> void:
	if(body.name == "Player"):
		body.can_surface = false
