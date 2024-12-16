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
	suffix.get_prefix_mana_values(prefix.get_mana_values())
	
	# After spell definition, determine both its name and mana cost(s)
	determine_spell_name()
	mana_cost = calculate_mana_cost()

#region Spell Setup Functions
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
#endregion

#region Spellcasting and Spell State Management

# Behaviours for SINGLE_CAST spells between key-down and key-up. Also sets
# PRESS_AND_HOLD spells to be active
func on_precast_spell():
	suffix.precast()

# Either cast the spell if SINGLE_CAST, switch value of is_active if TOGGLE, or
# deactivate PRESS_AND_HOLD spells.
func on_cast_spell():
	# Actual behaviour here determined by the spell cast type. This behavioural split has to 
	# happen here because the player just activates this generic function from their input hotkey.
	match(suffix.cast_type):
		# "One-and-done" spells require colour input here to determine their 
		# specific numbers, and cannot be cast if on cooldown.
		SpellSuffix.CAST_TYPES.SINGLE_CAST:
			if(!is_on_cooldown):
				suffix.cast(prefix.num_red_mana, prefix.num_blue_mana, 
				prefix.num_green_mana, prefix.num_white_mana, 
				prefix.num_black_mana, prefix.num_colorless_mana)
			else:
				print("%s Spells are on Cooldown!")
				return
		
		# NOTE: Toggles have their numbers passed into suffix.do_effect. Subject to
		# change depending on how tedious it gets.
		SpellSuffix.CAST_TYPES.TOGGLE:
			# Need to track what state this spell was in originally, so we
			# know where it should end up after this toggle takes place.
			var original_state := suffix.is_active
			# Turn off every Toggled Spell with the same suffix as this spell, then
			# set the value for this spell accordingly
			for s in player.active_spells:
				if(s == null || s.suffix.cast_type != SpellSuffix.CAST_TYPES.TOGGLE):
					continue
				if(s.get_suffix_id() == suffix.suffix_id):
					s.suffix.set_active(false)
					print("Toggled %s off"%[s.get_spell_name()])
			if(original_state == false):
				suffix.set_active(true)
				print("Toggled %s on"%[get_spell_name()])
		SpellSuffix.CAST_TYPES.PRESS_AND_HOLD:
			suffix.set_active(false)

# Create the a continual effect within the world. TOGGLE and PRESS_AND_HOLD spells
# use this for their actual in-game effect rather than on_cast_spell().
func do_passive_effect(_delta:float):
	suffix.do_effect(prefix.num_red_mana, prefix.num_blue_mana, prefix.num_green_mana, 
	prefix.num_white_mana, prefix.num_black_mana, prefix.num_colorless_mana)
	
	do_mana_cost(_delta)

#endregion

#region Mana Cost Utilities
# TODO Try finding a way to refactor check_mana_cost and do_mana_cost 
# into a single function to reduce the number of iterative loops per frame.
## Check whether the player has enough mana to cast a spell or keep it active.
func check_mana_cost() -> bool:
	
	for i in 6:
		var color_mana_cost := mana_cost[i]
		var color_mana_bar := player.mana_value_trackers[i] as ManaValueTracker
		if(color_mana_bar.current_mana < color_mana_cost):
			# i.e. Player does not have enough mana to cast this spell, 
			# or continue having this spell active.
			return false 
	
	return true

## Remove the appropriate amount of mana from each of the player's mana bars.
## contains a delta input for removal-over-time. If doing the whole cost in a single
## instance, do not pass a parameter into this function.
func do_mana_cost(delta:=1.0):
	## Reduce the player's mana values according to this spell's cost.
	for i in 6:
		var color_mana_cost := mana_cost[i] * delta
		var color_mana_bar := player.mana_value_trackers[i] as ManaValueTracker
		color_mana_bar.current_mana -= color_mana_cost

#endregion

#region Assorted Getters
func get_spell_name() -> String:
	return spell_name

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
func get_cast_type() -> SpellSuffix.CAST_TYPES:
	return self.suffix.cast_type
#endregion
