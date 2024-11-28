class_name BoltSuffix extends SpellSuffix

const PROJECTILE_PREFAB = preload("res://scene_prefabs/spell_objects/projectiles/bolt_projectile.tscn")

func _init() -> void:
	suffix_name = "Bolt"
	suffix_id = 0
	
	cast_type = CAST_TYPES.CAST_WITH_COOLDOWN
	is_active = true
	target_type = TARGET_TYPES.RAW_DIRECTION
	base_mana_cost = 10
	
	spell_icon = preload(icon_root_path + "bolt_icon.png")
	
	cooldown_max = 2.0

func calc_mana_cost():
	print("NOTE: Using Mana Calc from inherited class.")

func cast(num_red:int, num_blue:int, 
num_green:int, num_white:int, num_black:int, 
num_colourless:int):
	# Spell Functionality here:
	# Get Direction
	var travel_dir:float = player.get_dir_to_crosshair()
	# Instantiate Bolt prefab with correct shader and
	# colour bonuses.
	var new_projectile = PROJECTILE_PREFAB.instantiate()
	new_projectile.position = player.cast_origin.global_position
	new_projectile.rotation = player.get_dir_to_crosshair()
	new_projectile.initialise_shader(self.colors_from_prefix)
	#print("Initialising Bolt with %d Red/ %d Blue/ %d Green/ %d White/ %d Black/ %d CL"%[num_red, num_blue, num_green, num_white, num_black, num_colourless])
	new_projectile.initialise_prefix_effects(num_red, num_blue, num_green, num_white, num_black, num_colourless)
	
	player.add_sibling(new_projectile)
	# TODO Start Cooldown.
