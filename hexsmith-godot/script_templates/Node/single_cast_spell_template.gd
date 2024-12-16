## SUFFIX DESCRIPTION HERE, FOLLOWED BY MANA EFFECTS:
## Red: Effect from adding Red Mana
## Blue: Effect from adding Blue Mana
## Green: Effect from adding Green Mana
## White: Effect from adding White Mana
## Black: Effect from adding Black Mana
# meta-name: Single Cast Spell
# meta-description: Spell Suffix with SINGLE_CAST Cast Type
# meta-default: true
# meta-space-indent: 4
class_name SingleCastSpell extends SpellSuffix

## NOTE: If the spell has a Projectile, put the prefab file path here!
#const PROJECTILE_PREFAB = preload("res://scene_prefabs/spell_objects/projectiles/bolt_projectile.tscn")

func _init() -> void:
	suffix_name = "SUFFIX NAME"
	suffix_id = 0
	
	cast_type = CAST_TYPES.SINGLE_CAST
	active_state = true
	## NOTE: This is Mana Cost Per Mana Instance - i.e. a RR spell with cost 2*[this value] in Red Mana
	## For Single-Casts, this is generally a one-time burst cost and is typically quite high.
	base_mana_cost = 0 
	
	## NOTE: Put the file path for the Spell Icon here
	spell_icon = preload(icon_root_path + "bolt_icon.png")
	
	cooldown_max = 2.0

## Overridden Function from base class spell_suffix.gd
func on_precast():
	## Spell-specific Precast Behaviours go here.
	
	## NOTE: Player Controller changes are all done via the player's State Machines.
	# TODO Instantiate Precast Particles
	# TODO Visualise Mana Cost on relevant Mana Bar(s)
	pass

## Overridden Function from base class spell_suffix.gd
func on_cast(_mana_values:Array[float]) -> void:
	## Cast Behaviours go here. For a general overview/example of 'Object Spawner'
	## Spells, check bolt_suffix.gd Cooldowns are managed via player_controller.gd
	## and don't need to be put here.
	pass
