class_name BoltSuffix extends SpellSuffix

const PROJECTILE_PREFAB = preload("res://scene_prefabs/spell_objects/bolt_projectile.tscn")

func _init() -> void:
	suffix_name = "Bolt"
	
	cast_type = CAST_TYPES.CAST_WITH_COOLDOWN
	is_active = true
	target_type = TARGET_TYPES.RAW_DIRECTION
	
	spell_icon = preload(icon_root_path + "bolt_icon.png")

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
	new_projectile.initialise_prefix_effects(num_red, num_blue, num_green, num_white, num_black, num_colourless)
	
	player.add_sibling(new_projectile)
	# Start Cooldown.
	print("TODO %s casted a Bolt Spell"%[player.name])
