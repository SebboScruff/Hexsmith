# Used in State Machines, to manage transitionary behaviours and 
# frame-by-frame processing
class_name PlayerState
extends Node

var player:Player
var hud_manager:HudManager

var state_name:String
var state_id: int

signal State_Transition

func on_state_enter() -> void:
	pass
	
@warning_ignore("unused_parameter")
func on_state_process(delta:float) -> void:
	pass
	
@warning_ignore("unused_parameter")
func on_state_physics_process(delta:float) -> void:
	## NOTE: Any State Transitions that must be possible from any other state are done here,
	## and inherited into all other state classes via super.on_state_physics_process()
	# All states must be able to go to System Pause
	if(Input.is_action_just_pressed("global_system_pause")):
		State_Transition.emit(self, "paused")
	# All states must be able to go to Loadout Pause 
	elif(!player.is_paused && Input.is_action_just_pressed("global_loadout_pause")):
		State_Transition.emit(self, "paused")
	# All States (other than the pauses) must be able to go to the Spellcraft State.
	elif(!player.is_paused && !player.is_in_loadout &&
	Input.is_action_just_pressed("toggle_spellcraft_menu")):
		State_Transition.emit(self, "spellcraft")
	# All states must also be able to enter Cutscenes and Dialogue.
	## TODO Add generic transition into cutscenes and dialogue
	
func on_state_exit() -> void:
	pass
	
func check_spellcast_transitions():
	if(Input.is_action_just_pressed("overworld_cast_spellslot1")):
		if(player.active_spells[0] != null):
			match(player.active_spells[0].get_cast_type()):
				SpellSuffix.CAST_TYPES.SINGLE_CAST:
					State_Transition.emit(self, "precast")
					player.spellcast_state_machine.current_state.spell_slot_index = 0
				SpellSuffix.CAST_TYPES.TOGGLE:
					pass ## No state change needed if toggling a spell
				SpellSuffix.CAST_TYPES.CHANNEL:
					State_Transition.emit(self, "channel")
					player.spellcast_state_machine.current_state.spell_slot_index = 0
	elif(Input.is_action_just_pressed("overworld_cast_spellslot2")):
		if(player.active_spells[1] != null):
			match(player.active_spells[1].get_cast_type()):
				SpellSuffix.CAST_TYPES.SINGLE_CAST:
					State_Transition.emit(self, "precast")
					player.spellcast_state_machine.current_state.spell_slot_index = 1
				SpellSuffix.CAST_TYPES.TOGGLE:
					pass ## No state change needed if toggling a spell
				SpellSuffix.CAST_TYPES.CHANNEL:
					State_Transition.emit(self, "channel")
					player.spellcast_state_machine.current_state.spell_slot_index = 1
	elif(Input.is_action_just_pressed("overworld_cast_spellslot3")):
		if(player.active_spells[2] != null):
			match(player.active_spells[2].get_cast_type()):
				SpellSuffix.CAST_TYPES.SINGLE_CAST:
					State_Transition.emit(self, "precast")
					player.spellcast_state_machine.current_state.spell_slot_index = 2
				SpellSuffix.CAST_TYPES.TOGGLE:
					pass ## No state change needed if toggling a spell
				SpellSuffix.CAST_TYPES.CHANNEL:
					State_Transition.emit(self, "channel")
					player.spellcast_state_machine.current_state.spell_slot_index = 2
	elif(Input.is_action_just_pressed("overworld_cast_spellslot4")):
		if(player.active_spells[3] != null):
			match(player.active_spells[3].get_cast_type()):
				SpellSuffix.CAST_TYPES.SINGLE_CAST:
					State_Transition.emit(self, "precast")
					player.spellcast_state_machine.current_state.spell_slot_index = 3
				SpellSuffix.CAST_TYPES.TOGGLE:
					pass ## No state change needed if toggling a spell
				SpellSuffix.CAST_TYPES.CHANNEL:
					State_Transition.emit(self, "channel")
					player.spellcast_state_machine.current_state.spell_slot_index = 3

func change_player_sprite_direction(direction:float):
## NOTE: Sprite "flipping" is done via x-axis scale to make sure attack hitboxes spawn in the right place.
	if direction > 0:
		player.body_sprite.scale.x = 1
	elif direction < 0:
		player.body_sprite.scale.x = -1
