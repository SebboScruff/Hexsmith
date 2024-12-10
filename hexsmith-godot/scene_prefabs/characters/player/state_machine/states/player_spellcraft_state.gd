## Changes the input style to Spellcraft. Allows the player to make new spells to use.
class_name PlayerSpellcraftState
extends AgentState

var player:Player

func _init(_player:Player) -> void:
	self.state_name = "Spellcrafting" # Probably just for debugging
	self.state_id = 1 # Set this for lookup tables
	self.player = _player
	
func on_state_enter() -> void:
	print("Player entered Spellcrafting State")
	# TODO Activate Player Spellcraft Animation here.
	Engine.time_scale = 0.1
	player.hud_manager.change_active_menu(1)
	#pass
	
func on_state_process() -> void:
	pass
	
func on_state_physics_process() -> void:
	## Spellcraft Input Processing
	## TODO Refactor away from horrible if-chain
	#region Mana Addition
	if(Input.is_action_just_pressed("spellcraft_add_red")):
		player.spellcrafter.add_active_mana_instance(player.spellcrafter.MANA_COLOURS.RED)
	elif(Input.is_action_just_pressed("spellcraft_add_blue")):
		player.spellcrafter.add_active_mana_instance(player.spellcrafter.MANA_COLOURS.BLUE)
	elif(Input.is_action_just_pressed("spellcraft_add_green")):
		player.spellcrafter.add_active_mana_instance(player.spellcrafter.MANA_COLOURS.GREEN)
	elif(Input.is_action_just_pressed("spellcraft_add_white")):
		player.spellcrafter.add_active_mana_instance(player.spellcrafter.MANA_COLOURS.WHITE)
	elif(Input.is_action_just_pressed("spellcraft_add_black")):
		player.spellcrafter.add_active_mana_instance(player.spellcrafter.MANA_COLOURS.BLACK)
	elif(Input.is_action_just_pressed("spellcraft_add_colorless")):
		player.spellcrafter.add_active_mana_instance(player.spellcrafter.MANA_COLOURS.COLOURLESS)
	#endregion
	
	#region Mana Removal
	elif(Input.is_action_just_pressed("spellcraft_remove_mana")):
		player.spellcrafter.remove_last_instance()
	elif(Input.is_action_just_pressed("spellcraft_clear_mana")):
		player.spellcrafter.clear_active_mana()
	#endregion
	
	#region Spell Slot Assignment
	elif(Input.is_action_just_pressed("spellcraft_bind_spellslot1")):
		player.spellcrafter.craft_and_bind(0)
		player.postcraft_cast_cd.start()
	elif(Input.is_action_just_pressed("spellcraft_bind_spellslot2")):
		player.spellcrafter.craft_and_bind(1)
		player.postcraft_cast_cd.start()
	elif(Input.is_action_just_pressed("spellcraft_bind_spellslot3")):
		player.spellcrafter.craft_and_bind(2)
		player.postcraft_cast_cd.start()
	elif(Input.is_action_just_pressed("spellcraft_bind_spellslot4")):
		player.spellcrafter.craft_and_bind(3)
		player.postcraft_cast_cd.start()
	#endregion
	pass
	
func on_state_exit() -> void:
	print("Player exited Spellcrafting State")
	Engine.time_scale = 1.0
	# pass
