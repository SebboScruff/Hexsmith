# Everything Player-related is done here:
# - All basic input processing, for movement/combat/spellcasting,
# - Resource management like Health and Mana,
# - Visual updates and animations.
# - Also contains references to the player's Combat Entity and Spellcraft Manager

class_name Player
extends CharacterBody2D

## Bools used for FSM State Management
## TODO Try and find a way to remove these because it kinda removes the purpose of the
## State Machine in a couple of ways. Most of them are unnecessary I think.
var accept_movement_input:= true # turned off when channelling a PRESS AND HOLD spell.
var is_paused:= false # Turned on when in System Pause
var is_in_loadout:=false # Turned on when in Loadout/Inventory Pause
var is_climbing := false # Turned on when within a climbable zone
var is_swimming := false # Turns on when within a swimming zone
var can_exit_water := false # Subset of swimming zones for when you can jump out

#region Movement Parameters
const BASE_COYOTE_TIME := 0.2 # How long in seconds is the grace period after leaving a platform
var coyote_time := BASE_COYOTE_TIME # if coyote time is ever changed, it can easily be reset to default

## Different Movement Speeds
const BASE_SPEED = 150.0 # Standard Walking
const RUN_SPEED = 200.0 # Sprinting (Shift Held)
const CRAWL_SPEED = 75.0 # Crouching/Crawling (S Held)
const SWIM_SPEED = 80.0 # Underwater speed in all directions

# If anything else needs to modify speed (consumable items, spell effects)
# it is done through this.
var external_speed_mult:float = 1.0

var current_speed : float # this will be set to any of the const SPEED values above.

	#region Underwater Parameters
var is_underwater := false ## Turned on/off by Movement State Machine
const MAX_OXYGEN = 5 ## Number of seconds the player can remain underwater by default
var current_oxygen:float
@onready var oxygen_meter:TextureProgressBar = %OxygenMeter # on-HUD meter for monitoring time left.
	#endregion

const JUMP_VELOCITY = -200.0 # this is jump height against gravity, in pixels, which is why it's quite high.

# Gravity strength is adjusted in different game states e.g. 0 when paused, weaker when underwater.
var gravity_scale:float = 1.0
#endregion

#region Spellcraft & Spellcasting Parameters
# All the crafted spells that the player has access to.
# TODO this needs to be transferred to save-state data.
var active_spells:Array[Spell]

# The parent object into which all spell cooldown timers will be placed.
@onready var spell_cooldowns_parent: Node = $SpellCooldowns
# The prefab timers with ID tied to them, for monitoring spell cooldowns.
const SPELL_COOLDOWN_TIMER_PREFAB = preload("res://scene_prefabs/spell_cooldown_timer.tscn")

# These represent the player's coloured Mana Resources,
# regenerating over time and being spent when using spells.
var mana_value_trackers:Array[ManaValueTracker]
# The path to go from overworld_hud to the Mana Value Tracker Objects.
const mana_tracker_path = "mana_hp_panelcontainer/HBoxContainer/mana_bars_vbox"
# Likewise as above but for HP values tied to the Player's CombatEntity
var hp_bar : TextureProgressBar
const hp_bar_path = "mana_hp_panelcontainer/HBoxContainer/hp_centercontainer"

# Shitty bandaid solution to stop newly-crafted spells from automatically casting.
# TODO Probably address this and make it less shitty
@onready var postcraft_cast_cd: Timer = $SpellcraftManager/spellcraft_cast_cd
var can_cast:bool = true 

#endregion

#region Combat Parameters
var is_melee_ready:bool # melee attacks have a short cooldown.
@export var is_using_melee:bool = false # for melee attack animations. Exported to AnimationPlayer.
@export var basic_melee_damage:float # initially set in expector. Needs to be moved to save data eventually.

# TODO eventually add stuff like int ComboCount, for the number of consecutive attacks the
# player can do, or Melee Damage Bonuses for temporary buffs and Blade spells.
#endregion

#region Child Node References
## The Animation Player is used for any time-sensitive interactions, or anything
## that wants an inbuilt, controllable delay. For example, melee attacks and dying.
@onready var animation_player: AnimationPlayer = $AnimationPlayer

## Reference to the player's visual body, for animation work and projectile instantiation
@onready var body_sprite: AnimatedSprite2D = $BodySprite # TODO Eventually split into Upper Body and Lower Body
@onready var cast_origin: Marker2D = $BodySprite/cast_origin # this is where spell projectiles originate from. Child of Body Sprite.
@onready var foot_location: Marker2D = $BodySprite/player_foot_location # If particles need to be instantiated at the player's feet, like dust clouds or Strider effects.
@onready var footstep_interval_timer: Timer = %footstep_interval_timer # Used for Strider effects, footstep sound clips, etc.
@onready var underfoot_raycast: RayCast2D = %underfoot_raycast # Used to extract the current underfoot terrain type.

## Player's on-screen HUD and the manager script behind it, used for 
## accessing which game state they are in currently and adjusting controls accordingly.
@onready var player_hud: CanvasLayer = %PlayerHUD
@export var hud_manager : HudManager = player_hud as HudManager

## The player's Spellcraft Manager (SCM) is the backbone of the game's spellcrafting system.
## Main behavioural body is in spellcraft_manager.gd
@onready var scm: Node = %SpellcraftManager
@export var spellcrafter := scm as SpellcraftManager

## The player's State Machine Runners for determining basically all
## runtime behaviours and state transitions.
@onready var movement_sm: PlayerFSMRunner = %MovementStateMachine
@export var movement_state_machine:PlayerFSMRunner = movement_sm as PlayerFSMRunner

@onready var spellcast_sm: PlayerFSMRunner = %SpellcastStateMachine
@export var spellcast_state_machine:PlayerFSMRunner = spellcast_sm as PlayerFSMRunner

# All of the player's health management is done through this CombatEntity
@onready var player_combat_entity: CombatEntity = %CombatEntity

@onready var melee_attack_cooldown: Timer = $BodySprite/melee_attack_hitbox/melee_attack_cooldown
#endregion

########################
## START OF FUNCTIONS ##
########################

# Set a whole bunch of initialisation values.
# TODO Most of these need to become saveable, readable data.
func _ready() -> void:
	movement_state_machine.reset_to_idle()
	spellcast_state_machine.reset_to_idle()
	
	## TODO Save/Load System to read in the player's active spells from save data.
	active_spells = [null, null, null, null]
	is_melee_ready = true
	
	oxygen_meter.max_value = MAX_OXYGEN
	current_oxygen = MAX_OXYGEN
	
	# TODO this is so shit lmao
	# if there is literally any other way of doing this, do that instead
	mana_value_trackers = [hud_manager.overworld_hud.get_node(mana_tracker_path+"/mana_tracker_red") as ManaValueTracker,
	hud_manager.overworld_hud.get_node(mana_tracker_path+"/mana_tracker_blue") as ManaValueTracker,
	hud_manager.overworld_hud.get_node(mana_tracker_path+"/mana_tracker_green") as ManaValueTracker,
	hud_manager.overworld_hud.get_node(mana_tracker_path+"/mana_tracker_white") as ManaValueTracker,
	hud_manager.overworld_hud.get_node(mana_tracker_path+"/mana_tracker_black") as ManaValueTracker,
	hud_manager.overworld_hud.get_node(mana_tracker_path+"/mana_tracker_colourless") as ManaValueTracker]
	
	
	player_combat_entity.health_bar_visual = hud_manager.overworld_hud.get_node(hp_bar_path+"/hp_bar") as TextureProgressBar
	player_combat_entity.update_health_visual()
	
	# NOTE The actual in-game visual cursor (for menu naviation and stuff) can be
	# customised in Project Settings->General->Display->Mouse Cursor
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

# All Resource Management - Mana & Health Regeneration, Oxygen while underwater,
# and other constant over-time effects like that will happen in here
func _process(delta: float) -> void:
#region Oxygen Management
	# TODO Eventually add a HasWaterbreathing bool. Blue-Mana Cloaks will give waterbreathing,
	# as well as maybe some consumable items.
	if(is_underwater):
		# Player is underwater
		current_oxygen -= delta
		if(current_oxygen < 0):current_oxygen=0
	elif(current_oxygen < MAX_OXYGEN):
		# Player is not underwater but still has somewhat empty lungs
		current_oxygen += delta
	
	#Update HUD Oxygen Bar
	oxygen_meter.value = current_oxygen
	if(oxygen_meter.value >= oxygen_meter.max_value):
		oxygen_meter.set_visible(false)
	else:
		oxygen_meter.set_visible(true)
		
	if(current_oxygen <= 0):
		# probably manage this through a Timer node?
		# i.e. onTimerTimeout, deal damage through the player's CombatEntity
		print("TODO Out of Oxygen, taking damage")
#endregion
	
	## NOTE: Mana Regen is managed on a per-tracker basis in 
	## mana_value_tracker.gd. Adjust mana regen values, or grant large 
	## individual increases through this where necessary.
	
	# Natural HP Regeneration
	# This may or may not be removed at a later time depending on how soulslike
	# this game is gonna end up.
	if(player_combat_entity.curr_health < player_combat_entity.max_health):
		player_combat_entity.gain_health(player_combat_entity.health_regen_rate * delta, true)
	
	# Manage Cooldowns, Passive Effects, and Mana Costs 
	# for all active spells.
	active_spell_management(delta)
	
# All input processing work is done in here
# as well as all related animation work. It's done in _physics_process() rather
# than _input() for now because I want it updated at a consistent rate
## TODO Full refactor of Input Management, ideally to move it out of _physics_process
## and also change it away from being a bunch of ugly if-chains.
@warning_ignore("unused_parameter")
func _physics_process(delta: float) -> void:
	# print("Angle to crosshair: %f"%[get_dir_to_crosshair()])
	# TODO Check for Item Usage Inputs when I get round to implementing Items.
	move_and_slide()

#region Movement Functions
## NOTE: Extracted out into a function so that it can be called in State Behaviours
func _apply_gravity(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta * gravity_scale

## NOTE: Similar to gravity, these have been turned into a function to 
## allow for access within State Behaviours.
## move_and_slide() MUST be called within state physics updates. 
func _apply_horizontal_input(_delta:float, _h_dir:float = 0):
	if(_h_dir != 0):
		velocity.x = _h_dir * current_speed
	else: # i.e. if h_dir == 0
		velocity.x = move_toward(velocity.x, 0, current_speed)

func _apply_vertical_input(_delta:float, _v_dir:float = 0) -> void:
	if(_v_dir != 0):
		velocity.y = _v_dir * current_speed
	else:
		velocity.y = move_toward(velocity.y, 0, current_speed)
#endregion


func assign_spell_to_slot(_slot_index:int, _new_spell:Spell) -> void:
	## Manage all unassignment behaviours first, then set the new spell
	# Don't bother doing unassignment call if the slot is already empty
	if(active_spells[_slot_index] != null):
		unassign_spell_from_slot(_slot_index)
	
	active_spells[_slot_index] = _new_spell
	hud_manager.change_spell_icon(_slot_index, _new_spell.prefix.spell_icon_frame, _new_spell.suffix.spell_icon)

func unassign_spell_from_slot(_slot_index:int) -> void:
	if(active_spells[_slot_index] == null):
		print("Attempting to unassign empty spell slot!")
		return
		
	var spell = active_spells[_slot_index]
	## Turn off the spell if it is TOGGLE or CHANNEL
	if(spell.get_cast_type() != SpellSuffix.CAST_TYPES.SINGLE_CAST):
		# This manages all the spell cleanup by itself. Function body is different
		# in all suffixes.
		spell.suffix.set_active_state(false, spell.prefix.get_mana_values())
	
	active_spells[_slot_index] = null
	hud_manager.reset_spell_icon_to_default(_slot_index)

func move_spell_to_new_slot(_current_index:int, _new_index:int) -> void:
	if(active_spells[_current_index] == null):
		print("Attempting to move empty spell slot!")
		return
	if(active_spells[_new_index] == null):
		assign_spell_to_slot(_new_index, active_spells[_current_index])
		unassign_spell_from_slot(_current_index)
		hud_manager.reset_spell_icon_to_default(_current_index)
	else: # i.e. new index already has a spell assigned
		swap_spell_slots(_current_index, _new_index)
	
func swap_spell_slots(_index_a:int, _index_b:int):
	if(active_spells[_index_a] == null || active_spells[_index_b] == null):
		print("Empty spell slot passed into Spell Swap Function!")
		return
		
	## Swap(a,b) => {temp = a; a = b; b = temp}
	# temp = a
	var temp_spell:Spell = active_spells[_index_a]
	# a = b
	assign_spell_to_slot(_index_a, active_spells[_index_b])
	# b = temp
	assign_spell_to_slot(_index_b, temp_spell)

#region Spellcasting Functions
# Allow the player to cast after exiting Spellcraft. Has a short delay to prevent autocasting.
func _on_spellcraft_cast_cd_timeout() -> void:
	can_cast = true

## spell_index parameter determines which of the player's active spells is being cast.
## should not ever be highter than active_spells.length
func precast_active_spell(spell_index:int):
	if(active_spells[spell_index] == null):
		print("No or Invalid spell in slot " + var_to_str(spell_index))
	else:
		active_spells[spell_index].precast_spell()

## As with precast_active_spell, the parameter here is the slot index and should be lower than
## active_spells.length
func cast_active_spell(spell_index:int):
	# Fail check 1: Player doesn't have a spell in that spell slot
	if(active_spells[spell_index] == null):
		print("No or Invalid spell in slot " + var_to_str(spell_index))
	# Checks 2 and 3 only apply to Casted Spells with Cooldowns.
	elif(active_spells[spell_index].get_cast_type() == SpellSuffix.CAST_TYPES.SINGLE_CAST):
		# Fail check 2: That spell is on Cooldown.
		if(active_spells[spell_index].is_on_cooldown):
			print("%s Spells are on Cooldown!"%[active_spells[spell_index].suffix.suffix_name])
			return
		# Fail Check 3: Player doesn't have enough mana to cast that spell.
		elif(active_spells[spell_index].check_mana_cost() == false):
			print("Not Enough Mana to cast %s"%[active_spells[spell_index].get_spell_name()])
			return
		# Mana Removal here for Single-Instance Cast-with-Cooldown spells.
		# Toggles have their mana done as an over-time drain.
		active_spells[spell_index].do_mana_cost()
	
	## All failchecks passed; now the spell can be cast.
	active_spells[spell_index].cast_spell()
	
	# If the casted spell has a cooldown, apply it after casting
	# by adding a new cooldown timer to the list.
	# Timers are initialised with the same ID as the Suffix so the 
	# Cooldown Progression algorithm in _ready() can work correctly.
	if(active_spells[spell_index].suffix.cast_type == SpellSuffix.CAST_TYPES.SINGLE_CAST):
		var new_cd_timer:SpellCooldownTimer
		var casted_suffix:SpellSuffix = active_spells[spell_index].suffix
		new_cd_timer = SpellCooldownTimer.create_new_cooldown_timer(casted_suffix.suffix_id, casted_suffix.cooldown_max)
		
		spell_cooldowns_parent.add_child(new_cd_timer)
#endregion

# TODO have an int parameter for tracking melee combos.
func basic_melee():
	#print("TODO Basic Melee")
	animation_player.play("melee_attack_1")
	is_melee_ready = false
	melee_attack_cooldown.start()

# Basic timer switch for managing cooldowns.
func _on_melee_attack_cooldown_timeout() -> void:
	is_melee_ready = true

#region Combat Entity Signals
@warning_ignore("unused_parameter")
func _on_combat_entity_damage_taken(raw_amount: float, amount: float, type: CombatEntity.DAMAGE_TYPES) -> void:
	pass
	# TODO Play a "Take Damage" animation of some description
	# Like red highlight or something.

func _on_combat_entity_healed() -> void:
	pass
	# TODO Play a "Healed" animation of some description
	# Like green particle or something
	# NOTE: This is specifically NOT called during basic health regen.

func _on_combat_entity_has_died() -> void:
	print("TODO Player died")
	# Until player death is properly implemented, this is just an instant full heal.
	# Don't really know what I want to do yet for actual player death.
	player_combat_entity.gain_health(player_combat_entity.max_health)
#endregion

#region Spell Management Functions
static func create_new_cooldown_timer(_id:int, _duration:float) -> SpellCooldownTimer:
	var new_timer:SpellCooldownTimer = SPELL_COOLDOWN_TIMER_PREFAB.instantiate()
	
	new_timer.timer_id = _id
	new_timer.wait_time = _duration
	new_timer.autostart = true
	
	return new_timer

# Used for basically all Spellcast-based projectile spawning
func get_dir_to_crosshair() -> float:
	var aim_angle:float
	
	var vector_diff:Vector2 = cast_origin.global_position - get_global_mouse_position()
	aim_angle = vector_diff.angle()
	
	return aim_angle

func active_spell_management(_delta_time:float) -> void:
	for n in active_spells.size():
		var spell := active_spells[n] as Spell
		## If that spellslot is empty, for minor optimisation and to avoid crashes/errors.
		if(spell == null):
			continue
		## Get the corresponding HUD icon - it's needed for HUD updates regardless of spell type
		var spell_icon := hud_manager.spell_icons[n] as SpellIcon

		## If the spell is a Cooldown Cast, we need to check if its suffix is currently on cooldown:
		if(spell.suffix.cast_type == SpellSuffix.CAST_TYPES.SINGLE_CAST):
			# Set the spell to be off-cooldown initially, then overwrite to being 
			# on cooldown where necessary.
			spell.is_on_cooldown = false
			for t in spell_cooldowns_parent.get_children():
				# Check for matching internal IDs
				# These are instantiated as soon as a spell is cast, and destroyed
				# when they time out, so there will never be more than 1 per suffix (or 9 total)
				if(t is SpellCooldownTimer && t.timer_id == spell.get_suffix_id()):
					## Corresponding Cooldown Timer found, that spell is now on cooldown.
					spell.is_on_cooldown = true
					spell_icon.update_cd_visual(t.wait_time, t.time_left)
					break # and proceed to next spell in the list
		# NOTE: Having gone through every timer without finding an ID match,
		# this spell is not on cooldown. The previously declared
		# spell.is_on_cooldown = false will be maintained, and we can go
		# to the next spell in the list.
			continue
		
		## If not a SINGLE_CAST, need to check if the spell is active and 
		## do its over-time effects accordingly
		else: # i.e. Currently interrogated Spell is TOGGLE or CHANNEL
			## UI Management First
			spell_icon.update_cd_visual(1, 0) # hacky way to remove the cooldown indicator
			spell_icon.set_highlight_state(spell.suffix.active_state)
			if(spell.suffix.active_state == true):
				# This function manages both behaviours, auto-turn-off conditions,
				# and mana cost activation
				spell.do_passive_effect(_delta_time)
				print("Doing Effect for %s"%[spell.get_spell_name()]) 
#endregion
