class_name Spell extends Node

var player: Player
var prefix: SpellPrefix
var suffix: SpellSuffix

var spell_name:String
# Stored as an array: 0,1,2,3,4,5 are Red,Blue,Green,White,Black,Colorless
# mana costs respectively. 
var mana_cost:Array[float]

func _init(_player:Player, _prefix:SpellPrefix, _suffix:SpellSuffix):
	# Needs a prefix and suffix to define itself as a spell, and also
	# requires a reference to the Player (that crafted it) so the cast suffix's 
	# cast behaviours can reference positions, cast costs, etc.
	prefix = _prefix
	suffix = _suffix
	player = _player
	
	suffix.player = _player
	suffix.get_prefix_colors(prefix.colors)
	
	#print("Initialised a %s %s to Player: %s"%[prefix.prefix_name, suffix.suffix_name, player.name])
	# then assign them and determine the spell name.
	determine_spell_name()
	mana_cost = calculate_mana_cost()

func determine_spell_name():
	spell_name = prefix.prefix_name + " " + suffix.suffix_name
	## TODO There is an edge-case where if the suffix is Summon Familiar.

func calculate_mana_cost() -> Array[float]:
	var costs:Array[float] = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
	
	# add mana costs based on A) Prefix Colours and B) Suffix basic cost.
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
		# specific numbers
			SpellSuffix.CAST_TYPES.CAST_WITH_COOLDOWN:
				#print("Casting %s"%[spell_name])
				
				suffix.cast(prefix.num_red_mana, prefix.num_blue_mana, 
				prefix.num_green_mana, prefix.num_white_mana, 
				prefix.num_black_mana, prefix.num_colorless_mana)
		
		# Toggles and passives have their numbers passed into suffix.do_effect. Subject to
		# change depending on how tedious it gets.
			SpellSuffix.CAST_TYPES.TOGGLE:
				suffix.toggle()
			
			SpellSuffix.CAST_TYPES.PASSIVE:
				print("Tried to cast %s but it is a Passive Spell."%[spell_name])

func get_mana_cost() -> float:
	return suffix.mana_cost
