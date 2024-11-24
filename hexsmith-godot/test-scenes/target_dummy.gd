# Debugging setup to check that all my Damage Values are working correctly. 
# The target dummy will consistently display values corresponding to the last
# time its CombatEntity took damage: the numerical value, and the damage type.

# Maybe we can drop on of these guys in the Arkranium at some point so people
# can play around with combos.
extends Node2D

@onready var last_damage_raw_amount: Label = $damage_readout/VBoxContainer/last_damage_raw_amount
@onready var last_damage_real_amount: Label = $damage_readout/VBoxContainer/last_damage_real_amount
@onready var last_damage_type: Label = $damage_readout/VBoxContainer/last_damage_type
@onready var total_damage_label: Label = $damage_readout/VBoxContainer/total_damage

@onready var combat_entity: CombatEntity = $CombatEntity

@onready var damage_readout_reset: Timer = $damage_readout/damage_readout_reset

var running_total_dmg:float

func _ready() -> void:
	print("Target Dummy has %d HP"%[combat_entity.curr_health])

func _on_combat_entity_has_died() -> void:
	print("How the hell did you kill the target dummy")
	combat_entity.curr_health = combat_entity.max_health
