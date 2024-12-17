## The Precast State is activated when the player casts a SINGLE_CAST spell.
## It allows for simultaneous movement and aiming, and returns to the player's 
## previous state after the cast is finished.

## NOTE:
## Perform a State Transitions with State_Transition.emit(self, "new_state_name")
## Play animations on the player with player.body_sprite.play("animation_name")
## Manipulate movement with player.gravity_scale and player.current_speed.
## Activate movement per frame with player._apply_gravity and player._apply_movement()

class_name PlayerPrecastState
extends PlayerSpellcastState

func _init() -> void:
	self.state_name = "Precast" # This is used as the dictionary Key
	self.state_id = 15 # Check Obsidian for IDs; these are maybe not useful.

## All behaviours that take place as the player enters this state go here,
## for example changing the HUD Style, setting bools, altering the game's Time Scale, or
## Removing Momentum.
func on_state_enter() -> void:
	super.on_state_enter()
	player.precast_active_spell(player.spellcast_state_machine.current_index)
	hud_manager.spell_icons[player.spellcast_state_machine.current_index].set_highlight_state(true)
	# TODO Small-duration time slow for JUICE and easier aiming

## Anything that the state does that doesn't care about stable update rate goes here.
func on_state_process(delta:float) -> void:
	super.on_state_process(delta)

## If the state has processes that need stable update rate, like
## Input processing or movement, put them in here.
func on_state_physics_process(delta:float) -> void:
#region STATE TRANSITIONS
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
#endregion

#region PHYSICS BEHAVIOURS
	# Flip the player sprite so that they face the crosshair
	if(player.get_dir_to_crosshair() >= -1.5 && player.get_dir_to_crosshair() < 1.5):
		change_player_sprite_direction(-1)
	else:
		change_player_sprite_direction(1)
#endregion

func on_state_exit() -> void:
	super.on_state_exit()
	hud_manager.spell_icons[player.spellcast_state_machine.current_index].set_highlight_state(false)
