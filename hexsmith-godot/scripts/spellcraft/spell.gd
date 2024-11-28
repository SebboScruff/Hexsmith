class_name Spell extends Node

var player: Player
var prefix: SpellPrefix
var suffix: SpellSuffix

var spell_name:String
# Stored as an array: 0,1,2,3,4,5 are Red,Blue,Green,White,Black,Colorless
# mana costs respectively.
# NOTE: Must be kept consistent with the player's Mana Value Tracker 
var mana_cost:Array[float]
var is_on_cooldown:bool = false

# Constructor to assemble the spell's basic definition and get an access point
# to the player's controller.
func _init(_player:Player, _prefix:SpellPrefix, _suffix:SpellSuffix):
	prefix = _prefix # Prefix: Specific Stats, Colours, Additional SFX, Pre-cast Particles
	suffix = _suffix # Suffix: Overall Spell behaviours, and general SFX.
	
	player = _player # Player reference so that the Suffix can determine cast origin & direction, or apply the correct effects.
	suffix.player = _player # As above.
	
	suffix.get_prefix_colors(prefix.colors) # Access the prefix's visual colors so shaders can be set up correctly
	
	# After spell definition, determine both its name and mana cost(s)
	determine_spell_name()
	mana_cost = calculate_mana_cost()

# Extremely simple string concatenation
func determine_spell_name():
	spell_name = prefix.prefix_name + " " + suffix.suffix_name
	## TODO There is an edge-case where if the suffix is Summon Familiar.
	## where the name is changed to "Summon [Prefix] Familiar"

func calculate_mana_cost() -> Array[float]:
	# Setup zeroes array to begin with
	var costs:Array[float] = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
	
	# Add mana costs based on A) Prefix Mana Input and B) Suffix basic cost.
	# This means that complex spells can have different mana costs even if their names are the same,
	# i.e. RRB Steam Spells are different to RBB (or RBC).
	# TODO There's definitely a more efficient way to do this
	costs[0] = suffix.base_mana_cost * prefix.num_red_mana
	costs[1] = suffix.base_mana_cost * prefix.num_blue_mana
	costs[2] = suffix.base_mana_cost * prefix.num_green_mana
	costs[3] = suffix.base_mana_cost * prefix.num_white_mana
	costs[4] = suffix.base_mana_cost * prefix.num_black_mana
	costs[5] = suffix.base_mana_cost * prefix.num_colorless_mana
	
	return costs

func precast_spell():
	# This will either print a message and do nothing (Toggles and Passives)
	# Or call the generic SpellSuffix precast() function
	suffix.precast()

func cast_spell():
	# Actual behaviour here determined by the spell cast type. This behavioural split has to 
	# happen here because the player just activates this generic function from their input hotkey.
	match(suffix.cast_type):
		# "One-and-done" spells require colour input here to determine their 
		# specific numbers, and cannot be cast if on cooldown.
		SpellSuffix.CAST_TYPES.CAST_WITH_COOLDOWN:
			if(!is_on_cooldown):
				suffix.cast(prefix.num_red_mana, prefix.num_blue_mana, 
				prefix.num_green_mana, prefix.num_white_mana, 
				prefix.num_black_mana, prefix.num_colorless_mana)
			else:
				print("%s Spells are on Cooldown!")
				return
		
		# Toggles and passives have their numbers passed into suffix.do_effect. Subject to
		# change depending on how tedious it gets.
		SpellSuffix.CAST_TYPES.TOGGLE:
			suffix.toggle()
			
		SpellSuffix.CAST_TYPES.PASSIVE:
			print("Tried to cast %s but it is a Passive Spell."%[spell_name])


## Assorted Getters ##

func get_mana_cost() -> float:
	return suffix.mana_cost

func get_prefix_name() -> String:
	return self.prefix.prefix_name
func get_prefix_id() -> int:
	return self.prefix.prefix_id

func get_suffix_name() -> String:
	return self.suffix.suffix_name
func get_suffix_id() -> int:
	return self.suffix.suffix_id
