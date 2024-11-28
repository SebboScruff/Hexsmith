extends Area2D

@onready var player: Player = $"../.."

func _on_body_entered(body: Node2D) -> void:
	# The way that this is currently set up, the CombatEntity instance
	# must be a direct child of the Collision Instance

	# TODO Might be able to refactor this a little bit to make it less awkward
	# but I could also just make sure all enemies have a roughly similar tree structure
	var hit_combat_entity:CombatEntity = body.get_node_or_null("CombatEntity") as CombatEntity
	
	if(hit_combat_entity == null):
		print("No Combat Entity found on Melee Attack Collision!")
		return
		
	hit_combat_entity.take_damage(player.basic_melee_damage, CombatEntity.DAMAGE_TYPES.PHYSICAL)
	pass # Replace with function body.
