## The Bolt Suffix fires a projectile which carries both elemental damage and a varied
## secondary effect depending on Mana Input:
## Red (Blazing Bolt): Projectile is a Fire System Entity, carrying the Igniter tag
## Blue (Aqua Bolt): Projectile is a Fire System Entity, carrying the Extinguisher tag
## Green (Phyto Bolt): Projectile is a Fire System Entity, carrying the Flammable tag
## White (Lumina Bolt): Projectile carries a point light that pierces dark caverns
## Black (Noctis Bolt): Projectile does not collide with terrain
class_name BoltSuffix extends SpellSuffix

const PROJECTILE_PREFAB = preload("res://scene_prefabs/spell_objects/projectiles/bolt_projectile.tscn")

func _init() -> void:
	suffix_name = "Bolt"
	suffix_id = 0
	
	cast_type = CAST_TYPES.SINGLE_CAST
	active_state = true
	base_mana_cost = 10
	
	spell_icon = preload(icon_root_path + "bolt_icon.png")
	
	cooldown_max = 2.0

## Overridden Function from base class spell_suffix.gd
func on_precast():
	## NOTE: Player Controller changes are all done via the player's State Machines.
	# TODO Instantiate Precast Particles
	# TODO Visualise Mana Cost on relevant Mana Bar(s)
	pass

## Overridden Function from base class spell_suffix.gd
func on_cast(_mana_values:Array[float]) -> void:
	# Instantiate new Bolt Projectile, and assign relevant values to it
	# then send it on its way
	var new_projectile = PROJECTILE_PREFAB.instantiate()
	
	new_projectile.position = player.cast_origin.global_position
	new_projectile.rotation = player.get_dir_to_crosshair()
	
	## NOTE: Function Bodies in bolt_projectile.gd
	new_projectile.initialise_shader(self.colors_from_prefix)
	new_projectile.initialise_prefix_effects(_mana_values[0], _mana_values[1], 
	_mana_values[2], _mana_values[3], _mana_values[4], _mana_values[5])
	
	player.add_sibling(new_projectile)
