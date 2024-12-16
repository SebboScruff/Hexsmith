## SUFFIX DESCRIPTION HERE, FOLLOWED BY MANA EFFECTS:
## Red: Effect from adding Red Mana
## Blue: Effect from adding Blue Mana
## Green: Effect from adding Green Mana
## White: Effect from adding White Mana
## Black: Effect from adding Black Mana
# meta-name: Toggled Spell
# meta-description: Spell Suffix with TOGGLE Cast Type
# meta-default: true
# meta-space-indent: 4
class_name ToggledSpell extends SpellSuffix

func _init() -> void:
	suffix_name = "SUFFIX NAME"
	
	cast_type = CAST_TYPES.TOGGLE
	active_state = false
	
	## NOTE: This is Mana Cost Per Mana Instance - i.e. a RR spell with cost 2*[this value] in Red Mana
	## For Toggles, this is generally per second and should be relatively low.
	base_mana_cost = 0
	
	## NOTE: Put the file path for the Spell Icon here
	spell_icon = preload(icon_root_path + "strider_icon.png")

## NOTE: No Inheritance into set_active_state function so that base class implementation is used.

## Overridden Function from base class spell_suffix.gd
func on_activate(_mana_values:Array[float]) -> void:
	super.on_activate(_mana_values)
	
	## Any special effects that happen when the spell is activated go here.

## Overridden Function from base class spell_suffix.gd
func on_deactivate(_mana_values:Array[float]) -> void:
	super.on_deactivate(_mana_values)
	
	## Undo any changes made in on_activate().

## Overridden Function from base class spell_suffix.gd
func on_passive_effect(_mana_values:Array[float]):
	## Called every frame while the spell is active (i.e. active_state = true)
	## This will typically be either turning is_mana_cost_active on and off
	## under various conditions, or toggling the whole spell off automatically.
	## Remember to call player.spellcast_state_machine.reset_to_idle() if toggling
	## the spell off.
	pass
