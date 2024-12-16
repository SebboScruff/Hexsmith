# Used for monitoring when the player enters and exits a patch of water. This is basically just a 
# standalone state manager.

# Water Zone Node Tree Explanation:
# - water_max_height (marker) signifies the highest vertical co-ordinate of this body of water.
# It is used to determine how high up the player can go while in the Swim State
# - water_walkable (StaticBody2D) is the hard one-way collider that allows agents to move on
# the water's surface - for example, the player with Aqua Strider. Collision Layer = 6
# - water_surface (Area2D) is the collision area that puts the player into the Swim State,
# allowing for free vertical movement up to a certain height.
# - underwater_area (Area2D) is the area that puts the player into the Underwater State,
# allowing for free vertical movement and draining oxygen.
# - exit_zone (Area2D) is the collision area that enables the player to jump out of the water.

extends Node2D

@onready var water_max_height: Marker2D = $water_max_height

#region Surface Area Collision Events
func _on_water_surface_body_entered(body: Node2D) -> void:
	if(body is Player):
		body.movement_state_machine.change_state(body.movement_state_machine.current_state, "swim")
		body.movement_state_machine.current_state.max_height = water_max_height.global_position.y

func _on_water_surface_body_exited(body: Node2D) -> void:
	if(body is Player && !body.is_underwater):
		body.movement_state_machine.reset_to_idle()
#endregion
#region Underwater Area Collision Events
func _on_underwater_area_body_entered(body: Node2D) -> void:
	if(body is Player):
		body.movement_state_machine.change_state(body.movement_state_machine.current_state, "underwater")

func _on_underwater_area_body_exited(body: Node2D) -> void:
	if(body is Player):
		body.movement_state_machine.change_state(body.movement_state_machine.current_state, "swim")
		body.movement_state_machine.current_state.max_height = water_max_height.global_position.y
#endregion
#region Exit Area Collision Events 
func _on_exit_zone_body_entered(body: Node2D) -> void:
	if(body is Player):
		body.can_exit_water = true

func _on_exit_zone_body_exited(body: Node2D) -> void:
	if(body is Player):
		body.can_exit_water = false
#endregion
