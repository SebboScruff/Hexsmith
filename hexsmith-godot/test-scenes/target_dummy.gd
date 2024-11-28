# Debugging setup to check that all my Damage Values are working correctly. 
# The target dummy will consistently display values corresponding to the last
# time its CombatEntity took damage: the numerical value, and the damage type.

# Maybe we can drop on of these guys in the Arkranium at some point so people
# can play around with combos.
extends Node2D

@onready var combat_entity: CombatEntity = $CombatEntity

func _ready() -> void:
	#print("Target Dummy has %d HP"%[combat_entity.curr_health])
	pass

func _on_combat_entity_has_died() -> void:
	print("How the hell did you kill the target dummy")
	combat_entity.curr_health = combat_entity.max_health
