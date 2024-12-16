## The default overworld state. The player starts as Idle, and returns if no other input
## is done.
class_name PlayerSpellcraftState
extends PlayerState

func _init() -> void:
	self.state_name = "Spellcraft"
	self.state_id = 1

func on_state_enter() -> void:
	player.can_cast = false
	## Timescale to 0.1 so the game slows down while crafting.
	Engine.time_scale = 0.1
	hud_manager.change_active_menu(hud_manager.spellcraft_hud)
	player.spellcast_state_machine.change_state(player.spellcast_state_machine.current_state, "no cast")
	#TODO Play Spellcrafting Animation

func on_state_process(delta:float) -> void:
	super.on_state_process(delta)

func on_state_physics_process(delta:float) -> void:
	super.on_state_physics_process(delta)
	
	## Check for Menu Transitions first
	# 1 - Back to Overworld
	if(Input.is_action_just_pressed("toggle_spellcraft_menu")):
		player.spellcrafter.menu_cleanup()
	# 2  - Into Journal/Spellbook Menu
	if(Input.is_action_just_pressed("spellcraft_open_spellbook")):
		player.spellcrafter.clear_active_mana()
		State_Transition.emit(self, "paused")
	
	## Check for Spellcraft Controls
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
	
	## And apply regular physics
	player._apply_gravity(delta)

func on_state_exit() -> void:
	hud_manager.change_active_menu(hud_manager.overworld_hud)
	player.spellcast_state_machine.change_state(player.spellcast_state_machine.current_state, "idle", 0.1)
	Engine.time_scale = 1.0
