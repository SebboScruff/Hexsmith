# Debugging setup to check that all my Damage Values are working correctly. 
# The target dummy will consistently display values corresponding to the last
# time its CombatEntity took damage: the numerical value, and the damage type.
extends StaticBody2D

@onready var last_damage_amount: Label = $damage_readout/VBoxContainer/last_damage_amount
@onready var last_damage_type: Label = $damage_readout/VBoxContainer/last_damage_type

func _on_combat_entity_damage_taken(amount: float, type: CombatEntity.DAMAGE_TYPES) -> void:
	last_damage_amount.text = var_to_str(amount)
	last_damage_type.text = CombatEntity.DAMAGE_TYPES.keys()[type]
