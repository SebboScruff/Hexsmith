# Everything Player-related is done here:
# - All basic input processing, for movement/combat/spellcasting,
# - Resource management like Health and Mana,
# - Visual updates and animations.
# - Also contains references to the player's Combat Entity and Spellcraft Manager

class_name Player
extends CharacterBody2D

#region Movement Parameters
# Used for altering the player's fundamental movement behaviours.
enum MOVEMENT_STYLES{ 
	NORMAL,		# default Movement State
	CUTSCENE,	# Movement disabled (reading a sign, talking to an NPC, etc.)
	SWIMMING,	# Free vertical movement, reduced gravity. Underwater. Toggled with Zones. Priority over Climbing.
	CLIMBING,	# Free vertical movement, no gravity. Ladders, rugged walls, etc. Toggled with Zones.
	FLYING		# Free vertical movement, no gravity. Flight Spell. Movement costs Mana.
}
var current_movement_style:MOVEMENT_STYLES

# Different Speed declarations
const BASE_SPEED = 150.0 # Standard Walking
const RUN_SPEED = 200.0 # Sprinting (Shift Held)
const CRAWL_SPEED = 75.0 # Crouching/Crawling (S Held)
const SWIM_SPEED = 80.0 # Underwater speed in all directions

# If anything else needs to modify speed (consumable items, spell effects)
# it is done through this.
var external_speed_mult:float = 1.0

var current_speed : float # this will be set to any of the const SPEED values above.

	#region Underwater Parameters
# SWIM_SPEED must be multiplied and made negative to overcome
# gravity and move in the correct direction
var can_surface:bool = false # turned on whenever player is within a surfaceable region - usually water shores
const MAX_OXYGEN = 5 ## Number of seconds the player can remain underwater by default
var current_oxygen:float
@onready var oxygen_meter:TextureProgressBar = %OxygenMeter # on-HUD meter for monitoring time left.
	#endregion

const JUMP_VELOCITY = -200.0 # this is jump height against gravity, in pixels, which is why it's quite high.

# Gravity strength is adjusted in different game states e.g. 0 when paused.
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

var is_precasting:bool 
#endregion

#region Combat Parameters
var is_melee_ready:bool # melee attacks have a short cooldown.
@export var is_using_melee:bool = false # for melee attack animations. Exported to AnimationPlayer.
@export var basic_melee_damage:float # initially set in expector. Needs to be moved to save data eventually.

# TODO eventually add stuff like int ComboCount, for the number of consecutive attacks the
# player can do, or Melee Damage Bonuses for temporary buffs and Blade spells.
#endregion

#region Child Node References
# The Animation Player is used for any time-sensitive interactions, or anything
# that wants an inbuilt, controllable delay. For example, melee attacks and dying.
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Reference to the player's visual body
@onready var body_sprite: AnimatedSprite2D = $BodySprite
@onready var cast_origin: Marker2D = $BodySprite/cast_origin # this is where spell projectiles originate from. Child of Body Sprite.

# Player's on-screen HUD and the manager script behind it, used for 
# accessing which game state they are in currently and adjusting controls accordingly.
@onready var player_hud: CanvasLayer = $PlayerHUD
@export var hud_manager : HudManager = player_hud as HudManager

# The player's Spellcraft Manager (SCM) is the backbone of the game's spellcrafting system.
# Main behavioural body is in spellcraft_manager.gd
@onready var scm: Node = %SpellcraftManager
@export var spellcrafter: SpellcraftManager = scm as SpellcraftManager

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
	is_precasting = false
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
	if(current_movement_style == MOVEMENT_STYLES.SWIMMING and !can_surface):
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
	
	# HP Regen managed here.
	if(player_combat_entity.curr_health < player_combat_entity.max_health):
		player_combat_entity.gain_health(player_combat_entity.health_regen_rate * delta, true)
		
	# This is set up in a way where all spells with the same Suffix will share a cooldown.
	# So if you cast a BOLT Spell, all possible BOLT spells go on cooldown.
	# Likewise, casting a BOLT spell then putting a different spell in that slot
	# will potentially take it off cooldown.
	# 9 Suffixes have cooldowns so worst case this has to run 36 times, but that
	# requires a player casting literally every single spell with a cooldown before
	# the first one ends.
	#region Spell Cooldown Management Algorithm:
	for n in active_spells.size():
		var spell := active_spells[n] as Spell
		# If that spellslot is empty, go to next one immediately.
		if(spell == null):
			continue
		# Set the spell to be off-cooldown initially, then overwrite to being 
		# on cooldown where necessary.
		spell.is_on_cooldown = false
		# Get the corresponding HUD icon
		var spell_icon := hud_manager.spell_icons[n] as SpellIcon
		# Minor optimisation to auto-skip any spells that don't have cooldowns, 
		# i.e. toggles and passives. Also resets the cooldown visual for those spells.
		if(spell.suffix.cast_type != SpellSuffix.CAST_TYPES.CAST_WITH_COOLDOWN):
			spell_icon.update_cd_visual(1, 0)
			continue
		# Iterate through all current Cooldown Timers.
		# These are instantiated as soon as a spell is cast, and destroyed
		# when they time out, so there will never be more than 1 per suffix
		# (i.e. more than 9 in total).
		for t in spell_cooldowns_parent.get_children():
			var cdt := t as SpellCooldownTimer # cast as specialised timer with ID
			# Check for matching internal IDs
			if(cdt.timer_id == spell.get_suffix_id()):
				## Corresponding Cooldown Timer found, that spell is now on cooldown.
				spell.is_on_cooldown = true
				spell_icon.update_cd_visual(cdt.wait_time, cdt.time_left)
				break # and proceed to next spell in the list
		## Having gone through every timer without finding an ID match,
		## this spell is not on cooldown. The previously declared
		## spell.is_on_cooldown = false will be maintained. 
	#endregion
	
# All input processing work is done in here
# as well as all related animation work. It's done in _physics_process() rather
# than _input() for now because I want it updated at a consistent rate
## TODO Full refactor of Input Management, ideally to move it out of _physics_process
## and also change it away from being a bunch of ugly if-chains.
func _physics_process(delta: float) -> void:
	# Menu Changing Checks are done first, so that we can pause the game at the start
	# of a frame rather than partway through.
#region Menu Input Checks
	match(gsm.current_game_state):
		States.GAME_STATES.OVERWORLD:
			if(Input.is_action_just_pressed("global_pause")):
				gsm.change_game_state(States.GAME_STATES.PAUSED)
				hud_manager.change_active_menu(2)
			elif(Input.is_action_just_pressed("toggle_spellcraft_menu")):
				gsm.change_game_state(States.GAME_STATES.SPELLCRAFTING)
				hud_manager.change_active_menu(1)
				can_cast = false
		
		States.GAME_STATES.SPELLCRAFTING:
			# Clear out the active mana selection before changing menus
			if(Input.is_action_just_pressed("spellcraft_open_spellbook")):
				spellcrafter.clear_active_mana()
				gsm.change_game_state(States.GAME_STATES.PAUSED)
				# TODO Extend this to specifically open the pause menu ON the Spellbook tab
				hud_manager.change_active_menu(2)
			elif(Input.is_action_just_pressed("toggle_spellcraft_menu")):
				spellcrafter.clear_active_mana()
				gsm.change_game_state(States.GAME_STATES.OVERWORLD)
				hud_manager.change_active_menu(0)
				postcraft_cast_cd.start()
		
		States.GAME_STATES.PAUSED:
			if(Input.is_action_just_pressed("global_pause")):
				gsm.change_game_state(States.GAME_STATES.OVERWORLD)
				hud_manager.change_active_menu(0)
		
		States.GAME_STATES.CUTSCENE:
			if(Input.is_action_just_pressed("global_pause") ||
			Input.is_action_just_pressed("overworld_interact")):
				gsm.change_game_state(States.GAME_STATES.OVERWORLD)
				hud_manager.change_active_menu(0)
#endregion

	# If paused, ignore all player-based physics processes.
	if(gsm.current_game_state == States.GAME_STATES.PAUSED):
		return
	
#region Gravity
	# Gravity processing is the first thing to be checked, so that the player will still 
	# fall even if they are in the Spellcraft Menu
	# Gravity has different effective strengths depending on the player's movement state.
	match(current_movement_style):
		MOVEMENT_STYLES.NORMAL:
			gravity_scale = 1.0
		MOVEMENT_STYLES.SWIMMING:
			gravity_scale = 0.5
		MOVEMENT_STYLES.CLIMBING:
			gravity_scale = 0
		MOVEMENT_STYLES.FLYING:
			gravity_scale = 0
	
	# Then apply gravity where necessary
	if not is_on_floor():
		velocity += get_gravity() * delta * gravity_scale
#endregion
	
	# If in a cutscene, register gravity-based movement but don't accept other controls
	# so if the player starts reading a sign mid-air they still fall to the ground
	if(gsm.current_game_state == States.GAME_STATES.CUTSCENE):
		move_and_slide()
		return
	
	# NOTE: Direction is declared outside of any input checks because otherwise
	# the animation code will break. It's used in movement and animation.
	var direction := Input.get_axis("overworld_move_left", "overworld_move_right")

# TODO Refactor Spellcraft inputs to not be a horrible if-chain
#region Spellcraft Menu Controls
	if(gsm.current_game_state == States.GAME_STATES.SPELLCRAFTING):
		#region Mana Addition
		if(Input.is_action_just_pressed("spellcraft_add_red")):
			spellcrafter.add_active_mana_instance(spellcrafter.MANA_COLOURS.RED)
		elif(Input.is_action_just_pressed("spellcraft_add_blue")):
			spellcrafter.add_active_mana_instance(spellcrafter.MANA_COLOURS.BLUE)
		elif(Input.is_action_just_pressed("spellcraft_add_green")):
			spellcrafter.add_active_mana_instance(spellcrafter.MANA_COLOURS.GREEN)
		elif(Input.is_action_just_pressed("spellcraft_add_white")):
			spellcrafter.add_active_mana_instance(spellcrafter.MANA_COLOURS.WHITE)
		elif(Input.is_action_just_pressed("spellcraft_add_black")):
			spellcrafter.add_active_mana_instance(spellcrafter.MANA_COLOURS.BLACK)
		elif(Input.is_action_just_pressed("spellcraft_add_colorless")):
			spellcrafter.add_active_mana_instance(spellcrafter.MANA_COLOURS.COLOURLESS)
		#endregion
		#region Mana Removal
		elif(Input.is_action_just_pressed("spellcraft_remove_mana")):
			spellcrafter.remove_last_instance()
		elif(Input.is_action_just_pressed("spellcraft_clear_mana")):
			spellcrafter.clear_active_mana()
		#endregion
		#region Spell Slot Assignment
		elif(Input.is_action_just_pressed("spellcraft_bind_spellslot1")):
			spellcrafter.craft_and_bind(0)
			postcraft_cast_cd.start()
		elif(Input.is_action_just_pressed("spellcraft_bind_spellslot2")):
			spellcrafter.craft_and_bind(1)
			postcraft_cast_cd.start()
		elif(Input.is_action_just_pressed("spellcraft_bind_spellslot3")):
			spellcrafter.craft_and_bind(2)
			postcraft_cast_cd.start()
		elif(Input.is_action_just_pressed("spellcraft_bind_spellslot4")):
			spellcrafter.craft_and_bind(3)
			postcraft_cast_cd.start()
		#endregion
#endregion

#region Overworld Controls
	#region Movement
	if(gsm.current_game_state == States.GAME_STATES.OVERWORLD):
		## BEGINNING OF MOVEMENT INPUT PROCESSING: ##
		# Horizontal Movement is done at the end of this match block.
		# The player's vertical movmement, speed, etc. are all set differently depending on 
		# their current movement state
		match(current_movement_style):
			# Regular Overworld Controls
			MOVEMENT_STYLES.NORMAL:
				# Check for Sprint inputs
				# This will eventually be expanded for many movement categories
				if(is_on_floor() && Input.is_action_just_pressed("overworld_down")):
					current_speed = CRAWL_SPEED
					# TODO Also reduce hitbox size
				elif(Input.is_action_pressed("overworld_toggle_sprint")):
					current_speed = RUN_SPEED
				else:
					current_speed = BASE_SPEED
				# Handle jump.
				if Input.is_action_pressed("overworld_jump"):
					if(is_on_floor() || can_surface):
						velocity.y = JUMP_VELOCITY
			
			# Underwater Movement Controls
			MOVEMENT_STYLES.SWIMMING:
				current_speed = SWIM_SPEED
				# Get the player's vertical movement as well
				var dir_v := Input.get_axis("overworld_up", "overworld_down")
				# If moving upwards, disregard gravity and replace with input.
				if(dir_v != 0):
					velocity -= get_gravity() * delta * gravity_scale
					velocity.y = dir_v * current_speed
				# Otherwise use (reduced) gravity value to make the player sink.
				else:
					velocity.y = get_gravity().y * delta * gravity_scale
				
				# If the player is within a surfaceable region, they can jump out of the water.
				if Input.is_action_pressed("overworld_jump") and can_surface:
					velocity.y = JUMP_VELOCITY
			
			# Ladder/ Climbable Wall Controls 
			MOVEMENT_STYLES.CLIMBING:
				# Free Vertical Movement with No Gravity. Gravity is already set to 0
				var dir_v := Input.get_axis("overworld_up", "overworld_down")
				velocity.y = dir_v * current_speed
			
			# Flight Spell Controls. NOTE: Loses mana per second while active.
			MOVEMENT_STYLES.FLYING:
				print("TODO Implement Flying")
				pass
		
		# Horizontal Deceleration: if not moving, reduce speed back to 0 gradually
		if direction:
			velocity.x = direction * current_speed
		else:
			velocity.x = move_toward(velocity.x, 0, current_speed)
			
	# Apply the MoveAndSlide regardless of whether the game is in Overworld
	# or Spellcraft, so that the player will continue falling due to gravity
	# even if Spellcrafting
	move_and_slide()
	#endregion
	
	# After moving, check for Spellcasting and Combat inputs:
	#region Spellcasting and Combat
	if(gsm.current_game_state == States.GAME_STATES.OVERWORLD):
		# Melee Input Check
		if(is_melee_ready && Input.is_action_just_pressed("overworld_melee_attack")):
				# TODO this can eventually have an int parameter for Combo Count
				# i.e. for hit 2 in the combo you call basic_melee(2)
				# or ideally basic_melee(current_melee_combo =+ 1)
				basic_melee()
		
		# TODO Eventually change this to animation_player.play(spellcast)
		# and call cast_active_spell through that. Gonna be a headache trying
		# to fanagle the right parameters.
		## TODO Once I start implementing player progression, also need to check
		## If the player has unlocked this spell slot. Probably will be intrinsically managed
		## in the previous conditional & the spellcraft menu: if the slot isnt unlocked, it just
		## wont complete the craft step and therefore the spell will be null
		
		# If precasting, release the selected spell.
		if(is_precasting):
			if(Input.is_action_just_released("overworld_cast_spellslot1")):
				cast_active_spell(0)
			elif(Input.is_action_just_released("overworld_cast_spellslot2")):
				cast_active_spell(1)
			elif(Input.is_action_just_released("overworld_cast_spellslot3")):
				cast_active_spell(2)
			elif(Input.is_action_just_released("overworld_cast_spellslot4")):
				cast_active_spell(3)
		
		# Otherwise, the player is allowed to start precasting
		elif(can_cast):
			if(Input.is_action_just_pressed("overworld_cast_spellslot1")):
				precast_active_spell(0)
			elif(Input.is_action_just_pressed("overworld_cast_spellslot2")):
				precast_active_spell(1)
			elif(Input.is_action_just_pressed("overworld_cast_spellslot3")):
				precast_active_spell(2)
			elif(Input.is_action_just_pressed("overworld_cast_spellslot4")):
				precast_active_spell(3)
			
	#endregion
#endregion

#region SPRITE ANIMATION
	# Flip depending on Movement Direction
	# NOTE: This is a scale manipulation rather than a sprite.flip_h() call
	# because the melee hitbox is childed to the sprite. The whole set needs
	# to be inverted in order for the hitboxes to be correct.
	# TODO Eventually this wants to change to be based on the cursor->player
	# angle if the player is precasting so they dont fire projectiles behind them
	if direction > 0:
		body_sprite.scale.x = 1
	elif direction < 0:
		body_sprite.scale.x = -1
		
	#Then determine animations
	if(gsm.current_game_state == States.GAME_STATES.SPELLCRAFTING):
		# If the player is in Spellcraft Mode, play a "Thinking" animation
		# and break out from _physics_process to ignore future animations
		# overwriting this.
		return

	# Melee attacks override all other animations
	if(is_using_melee):
		return
	
	# If not in Spellcrafting, the animations will depend entirely on the player's
	# current movement state.
	match(current_movement_style):
		MOVEMENT_STYLES.NORMAL:
			if is_on_floor():
				if direction == 0:
					body_sprite.play("idle")
				else:
					body_sprite.play("run")
			else:
				body_sprite.play("jump_whole")
		MOVEMENT_STYLES.SWIMMING:
			# TODO Swimming animations go here
			# Can probably toggle between swimming and treading water?
			pass
		MOVEMENT_STYLES.CLIMBING:
			# TODO Climbing animations go here
			# Will need a way to play/pause based on whether the player is moving
			# Either Horizontally or Vertically
			# and not play these until the player isn't on the ground.
			pass
		MOVEMENT_STYLES.FLYING:
			# Any flying animations go here.
			pass
#end of _physics_process function body.

#endregion SPRITE ANIMATION

# Used for basically all Spellcast-based projectile spawning
func get_dir_to_crosshair() -> float:
	var aim_angle:float
	
	var vector_diff:Vector2 = cast_origin.global_position - get_global_mouse_position()
	aim_angle = vector_diff.angle()
	
	return aim_angle

# Simple State Switch
func set_movement_style(new_style:MOVEMENT_STYLES):
	
	current_movement_style = new_style
	
	# Kill all current velocity-altering effects
	# so gravity doesn't continue to affect the player's velocity during state changes
	# Basically stops the player dropping like a rock if they switch to swimming or climbing.
	velocity = Vector2.ZERO

# Allow the player to cast after exiting Spellcraft. Has a short delay to prevent autocasting.
func _on_spellcraft_cast_cd_timeout() -> void:
	can_cast = true

# Nullcheck into external function call.
func precast_active_spell(spell_index:int):
	if(active_spells[spell_index] == null):
		print("No or Invalid spell in slot " + var_to_str(spell_index + 1))
	else:
		# TODO Play a "start-up" particle system and animation.
		# The animation will be tied to the player; the particles tied to the prefix.
		is_precasting = true
		active_spells[spell_index].precast_spell()

# Mana management and external function call.
func cast_active_spell(spell_index:int):
	# TODO Turn off precast particles here.
	is_precasting = false
	# Fail check 1: Player doesn't have a spell in that spell slot
	if(active_spells[spell_index] == null):
		print("No or Invalid spell in slot " + var_to_str(spell_index + 1))
	# Fail check 2: That spell is on Cooldown.
	elif(active_spells[spell_index].is_on_cooldown):
		# TODO Visual Indicator other than the cooldown bars.
		# Maybe like a fizzle-out particle effect or something 
		print("%s Spells are on Cooldown!"%[active_spells[spell_index].suffix.suffix_name])
		return
	else:
	# Fail Check 3: Player doesn't have enough mana to cast that spell.
		for m in mana_value_trackers:
			var i:int = m.get_index()
			if(m.current_mana < active_spells[spell_index].mana_cost[i]):
				print("Player does not have enough %s Mana to cast %s"%
				[SpellcraftManager.MANA_COLOURS.keys()[m.colour],active_spells[spell_index].spell_name])
				return
			# Mana Expenditure done while still in this for loop
			m.current_mana -= active_spells[spell_index].mana_cost[i]
		
		## All failchecks passed; now the spell can be cast.
		# Call that spell's Cast function - specific spell behaviours
		# are determined on a per-class basis
		active_spells[spell_index].cast_spell()
		
		# If the casted spell has a cooldown, apply it after casting
		# by adding a new cooldown timer to the list.
		# NOTE: Timers are initialised with the same ID as the Suffix so the 
		# Cooldown Progression algorithm in _ready() can work correctly.
		if(active_spells[spell_index].suffix.cast_type == SpellSuffix.CAST_TYPES.CAST_WITH_COOLDOWN):
			var new_cd_timer:SpellCooldownTimer
			var casted_suffix:SpellSuffix = active_spells[spell_index].suffix
			new_cd_timer = SpellCooldownTimer.create_new_cooldown_timer(casted_suffix.suffix_id, casted_suffix.cooldown_max)
			
			spell_cooldowns_parent.add_child(new_cd_timer)

# TODO have an int parameter for tracking melee combos.
func basic_melee():
	is_precasting = false
	#print("TODO Basic Melee")
	animation_player.play("melee_attack_1")
	is_melee_ready = false
	melee_attack_cooldown.start()

# Basic timer switch for managing cooldowns.
func _on_melee_attack_cooldown_timeout() -> void:
	is_melee_ready = true

#region Combat Entity Signals
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

static func create_new_cooldown_timer(_id:int, _duration:float) -> SpellCooldownTimer:
	var new_timer:SpellCooldownTimer = SPELL_COOLDOWN_TIMER_PREFAB.instantiate()
	
	new_timer.timer_id = _id
	new_timer.wait_time = _duration
	new_timer.autostart = true
	
	return new_timer
