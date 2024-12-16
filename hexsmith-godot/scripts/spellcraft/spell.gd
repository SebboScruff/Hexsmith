## A Container Class which combines a Prefix and Suffix into a single spell after Spellcrafting.
## Has a variety of functions that are accessed directly by the player, and are used to pass
## Prefix Data into Suffix Behaviours.
class_name Spell extends Node

var player: Player
var prefix: SpellPrefix
var suffix: SpellSuffix

var spell_name:String
# Stored as an array: 0,1,2,3,4,5 are Red,Blue,Green,White,Black,Colorless
# mana costs respectively.
# NOTE: Must be kept consistent with the player's Mana Value Tracker 
var mana_cost:Array[float]

# NOTE: Largely irrelevant for all non-SINGLE_CAST spells 
var is_on_cooldown := false

#region Set-Up Functions
# Constructor to assemble the spell's basic definition and get an access point
# to the player's controller.
func _init(_player:Player, _prefix:SpellPrefix, _suffix:SpellSuffix):
	prefix = _prefix # Prefix: Specific Stats, Colours, Additional SFX, Pre-cast Particles
	suffix = _suffix # Suffix: Overall Spell behaviours, and general SFX.
	
	player = _player # Player reference so that the Suffix can determine cast origin & direction, or apply the correct effects.
	suffix.player = _player # As above.
	
	## Pass the colors (TODO and sounds) straight into the Suffix as part of Spell Initialisation.
	suffix.colors_from_prefix = prefix.colors
	
	# After spell definition, determine both its name and mana cost(s)
	determine_spell_name()
	mana_cost = calculate_mana_cost()

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
	for i in 6:
		costs[i] = suffix.base_mana_cost * prefix.get_mana_values()[i]
		
	return costs
#endregion

#region Spellcasting and Spell State Management
# Either start precast behaviours if SINGLE_CAST, or activate spell effects
# if CHANNEL. No effect for TOGGLE.
func precast_spell():
	match(suffix.cast_type):
		SpellSuffix.CAST_TYPES.SINGLE_CAST:
			suffix.on_precast()
			
		SpellSuffix.CAST_TYPES.TOGGLE:
			print("No Precast Behaviours for Toggles Spells")
			pass
			
		SpellSuffix.CAST_TYPES.CHANNEL:
			suffix.set_active_state(true, prefix.get_mana_values())
			
		_:
			# This should never be reached but it's included as a 100% failsafe
			print("Invalid Cast Type on Precast Call!")
			return

# Either cast the spell if SINGLE_CAST, flip the value of active_state if TOGGLE, or
# deactivate if CHANNEL.
func cast_spell():
	match(suffix.cast_type):
		## All failchecks are done via player_controller.cast_active_spell()
		## so we can just go straight into spellcasting here.
		SpellSuffix.CAST_TYPES.SINGLE_CAST:
			suffix.on_cast(prefix.get_mana_values())
		
		## Turn off all Toggled Spells of the same type, then toggle this spell on.
		SpellSuffix.CAST_TYPES.TOGGLE:
			## If the spell was already on, it can just be turned off instantly.
			if(suffix.active_state == true):
				suffix.set_active_state(false, prefix.get_mana_values())
				return
			## If the spell is being turned on, we have to turn off every other
			## spell of that type before turning this one on.
			else: # i.e. spell is not currently active
				for s in player.active_spells:
					if(s == null || s.suffix.cast_type != SpellSuffix.CAST_TYPES.TOGGLE):
						continue
					if(s.get_suffix_id() == suffix.suffix_id):
						s.suffix.set_active_state(false, prefix.get_mana_values())
						print("Toggled %s off"%[s.get_spell_name()])
				suffix.set_active_state(true, prefix.get_mana_values())
				print("Toggled %s on"%[get_spell_name()])
		
		## Deactivate Channeled Spells on Key Up. Gives the effect of being a Press
		## and Hold activation system.
		SpellSuffix.CAST_TYPES.CHANNEL:
			suffix.set_active_state(false, prefix.get_mana_values())
		
		_:
			print("Invalid Cast Type in Cast Call!")

# Create the a continual effect within the world. TOGGLE and CHANNEL spells
# use this for their actual in-game effect rather than on_cast_spell().
func do_passive_effect(_delta:float):
	suffix.on_passive_effect(prefix.get_mana_values())
	
	if(suffix.is_mana_cost_active):
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
	
	# Gone through every mana bar without returning false, so we're good to go
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

#region Assorted Quick Getters
func get_spell_name() -> String:
	return spell_name

func get_mana_color_cost(_cost_index:int) -> float:
	return mana_cost[_cost_index]
func get_mana_cost() -> Array[float]:
	return mana_cost

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
