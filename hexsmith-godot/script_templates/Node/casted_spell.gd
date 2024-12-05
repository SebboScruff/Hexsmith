# meta-name: Casted Spell
# meta-description: Spell Suffix with CAST-WITH-COOLDOWN Cast Type
# meta-default: true
# meta-space-indent: 4
class_name CastedSpell extends SpellSuffix

# If the spell spawns a projectile, reference the prefab here. Otherwise, delete this.
const PROJECTILE_PREFAB = preload("res://scene_prefabs/spell_objects/projectiles/spell_projectile.tscn")

func _init() -> void:
	suffix_name = "Suffix Name"
	suffix_id = 0 # This is very important for cooldown management and lookup tables.
	
	cast_type = CAST_TYPES.CAST_WITH_COOLDOWN
	is_active = true
	target_type = TARGET_TYPES.RAW_DIRECTION
	base_mana_cost = 10
	
	spell_icon = preload(icon_root_path + "bolt_icon.png")
	
	cooldown_max = 0.0 # Set this!

func cast(num_red:int, num_blue:int, 
num_green:int, num_white:int, num_black:int, 
num_colourless:int):
	pass # Spell Functionality goes here:
	# Example for projectile spawning given below.
	#region IF SPAWNING PROJECTILE
	# Get Direction
	#var travel_dir:float = player.get_dir_to_crosshair()
	## Instantiate Bolt prefab with correct shader and
	## colour bonuses.
	#var new_projectile = PROJECTILE_PREFAB.instantiate()
	#new_projectile.position = player.cast_origin.global_position
	#new_projectile.rotation = player.get_dir_to_crosshair()
	#new_projectile.initialise_shader(self.colors_from_prefix)
	#new_projectile.initialise_prefix_effects(num_red, num_blue, num_green, num_white, num_black, num_colourless)
	
	#player.add_sibling(new_projectile)
	#endregion
