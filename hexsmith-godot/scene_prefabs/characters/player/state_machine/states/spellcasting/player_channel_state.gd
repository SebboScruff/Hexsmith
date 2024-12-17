## The Channel State is activated when the player casts a spell of Cast Type: CHANNEL.
## It 

## NOTE:
## Perform a State Transitions with State_Transition.emit(self, "new_state_name")
## Play animations on the player with player.body_sprite.play("animation_name")
## Manipulate movement with player.gravity_scale and player.current_speed.
## Activate movement per frame with player._apply_gravity and player._apply_movement()

class_name PlayerChannelState
extends PlayerSpellcastState

func _init() -> void:
	self.state_name = "Channel" # This is used as the dictionary Key
	self.state_id = 15 # Check Obsidian for IDs; these are maybe not useful.

## All behaviours that take place as the player enters this state go here,
## for example changing the HUD Style, setting bools, altering the game's Time Scale, or
## Removing Momentum.
func on_state_enter() -> void:
	super.on_state_enter()
	# Precast for CHANNEL spells just sets them to be active.
	player.precast_active_spell(player.spellcast_state_machine.current_index)
	hud_manager.spell_icons[player.spellcast_state_machine.current_index].set_highlight_state(true)
	player.accept_movement_input = false

## Anything that the state does that doesn't care about stable update rate goes here.
func on_state_process(delta:float) -> void:
	super.on_state_process(delta)

## If the state has processes that need stable update rate, like
## Input processing or movement, put them in here.
func on_state_physics_process(delta:float) -> void:
	## NOTE: Cast Behaviours for CHANNEL spells set them to be inactive
	match(player.spellcast_state_machine.current_index):
		0:
			if(Input.is_action_just_released("overworld_cast_spellslot0")):
				player.cast_active_spell(0)
				player.spellcast_state_machine.reset_to_idle()
		1:
			if(Input.is_action_just_released("overworld_cast_spellslot1")):
				player.cast_active_spell(1)
				player.spellcast_state_machine.reset_to_idle()
		2:
			if(Input.is_action_just_released("overworld_cast_spellslot2")):
				player.cast_active_spell(2)
				player.spellcast_state_machine.reset_to_idle()
		3:
			if(Input.is_action_just_released("overworld_cast_spellslot3")):
				player.cast_active_spell(3)
				player.spellcast_state_machine.reset_to_idle()
		_:
			print("Invalid state index in Precast State!")
			player.spellcast_state_machine.reset_to_idle()
#region STATE TRANSITIONS
	
#endregion

#region PHYSICS BEHAVIOURS
	## Movement and gravity is dealt with in base class PlayerSpellcastState
#endregion

func on_state_exit() -> void:
	super.on_state_exit()
	hud_manager.spell_icons[player.spellcast_state_machine.current_index].set_highlight_state(false)
	player.accept_movement_input = true
