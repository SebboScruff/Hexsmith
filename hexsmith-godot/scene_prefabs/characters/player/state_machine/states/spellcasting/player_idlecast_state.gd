## State Description Here!

## NOTE:
## Perform a State Transitions with State_Transition.emit(self, "new_state_name")
## Play animations on the player with player.body_sprite.play("animation_name")
## Manipulate movement with player.gravity_scale and player.current_speed.
## Activate movement per frame with player._apply_gravity and player._apply_movement()

class_name PlayerIdleCastState
extends PlayerState

func _init() -> void:
	self.state_name = "Idle" # This is used as the dictionary Key. Also called Idle so reset_to_idle works
	self.state_id = 14 # Check Obsidian for IDs; these are maybe not useful.

## All behaviours that take place as the player enters this state go here,
## for example changing the HUD Style, setting bools, altering the game's Time Scale, or
## Removing Momentum.
func on_state_enter() -> void:
	pass

## Anything that the state does that doesn't care about stable update rate goes here.
func on_state_process(delta:float) -> void:
	pass

## If the state has processes that need stable update rate, like
## Input processing or movement, put them in here.
func on_state_physics_process(delta:float) -> void:
#region STATE TRANSITIONS
	check_spellcast_transitions()
#endregion

#region PHYSICS BEHAVIOURS
	# No Physics behaviours for Spellcast Idle
#endregion

func on_state_exit() -> void:
	## No exit behaviours for Spellcast Idle.
	pass
	
func check_spellcast_transitions():
	if(Input.is_action_just_pressed("overworld_cast_spellslot0")):
		if(player.active_spells[0] != null):
			match(player.active_spells[0].get_cast_type()):
				SpellSuffix.CAST_TYPES.SINGLE_CAST:
					player.spellcast_state_machine.current_index = 0
					State_Transition.emit(self, "precast")
				SpellSuffix.CAST_TYPES.TOGGLE:
					pass ## No state change needed if toggling a spell
				SpellSuffix.CAST_TYPES.CHANNEL:
					player.spellcast_state_machine.current_index = 0
					State_Transition.emit(self, "channel")
		
	elif(Input.is_action_just_pressed("overworld_cast_spellslot1")):
		if(player.active_spells[1] != null):
			match(player.active_spells[1].get_cast_type()):
				SpellSuffix.CAST_TYPES.SINGLE_CAST:
					player.spellcast_state_machine.current_index = 1
					State_Transition.emit(self, "precast")
				SpellSuffix.CAST_TYPES.TOGGLE:
					pass ## No state change needed if toggling a spell
				SpellSuffix.CAST_TYPES.CHANNEL:
					player.spellcast_state_machine.current_index = 1
					State_Transition.emit(self, "channel")
		
	elif(Input.is_action_just_pressed("overworld_cast_spellslot2")):
		if(player.active_spells[2] != null):
			match(player.active_spells[2].get_cast_type()):
				SpellSuffix.CAST_TYPES.SINGLE_CAST:
					player.spellcast_state_machine.current_index = 2
					State_Transition.emit(self, "precast")
				SpellSuffix.CAST_TYPES.TOGGLE:
					pass ## No state change needed if toggling a spell
				SpellSuffix.CAST_TYPES.CHANNEL:
					player.spellcast_state_machine.current_index = 2
					State_Transition.emit(self, "channel")
		
	elif(Input.is_action_just_pressed("overworld_cast_spellslot3")):
		if(player.active_spells[3] != null):
			match(player.active_spells[3].get_cast_type()):
				SpellSuffix.CAST_TYPES.SINGLE_CAST:
					player.spellcast_state_machine.current_index = 3
					State_Transition.emit(self, "precast")
				SpellSuffix.CAST_TYPES.TOGGLE:
					pass ## No state change needed if toggling a spell
				SpellSuffix.CAST_TYPES.CHANNEL:
					player.spellcast_state_machine.current_index = 3
					State_Transition.emit(self, "channel")
