# The vast majority of direct input processing will be managed here, and then 
# various sub-effects will call functions in other places where necessary.
class_name Player
extends CharacterBody2D

#region Movement Parameters
enum MOVEMENT_STYLES{ # Used for altering the player's fundamental movement behaviours.
	NORMAL,		# default Movement State
	CUTSCENE,	# Movement disabled (reading a sign, talking to an NPC, etc.)
	SWIMMING,	# Free vertical movement, reduced gravity. Underwater. Toggled with Zones. Priority over Climbing.
	CLIMBING,	# Free vertical movement, no gravity. Ladders, rugged walls, etc. Toggled with Zones.
	FLYING		# Free vertical movement, no gravity. Flight Spell. Movement costs Mana.
}
var current_movement_style:MOVEMENT_STYLES

const BASE_SPEED = 150.0
const RUN_SPEED = 200.0
const CRAWL_SPEED = 75.0

	#region Underwater Parameters
const SWIM_SPEED = 80.0 # basic movement speed in all directions
# SWIM_SPEED must be multiplied and made negative to overcome
# gravity and move in the correct direction
const SWIM_VERTICAL_FACTOR = -1
var can_surface:bool = false # turned on whenever player is at the top of a patch of water
const MAX_OXYGEN = 5 ## Number of seconds the player can remain underwater by default
var current_oxygen:float
@onready var oxygen_meter:TextureProgressBar = %OxygenMeter
	#endregion

# If anything else needs to modify speed (consumable items, spell effects)
# it is done through this.
var external_speed_mult:float = 1.0
var current_speed : float

const JUMP_VELOCITY = -200.0
# Gravity strength is adjusted in different game states e.g. 0 when paused.
var gravity_scale:float = 1.0
#endregion

#region Spellcraft & Spellcasting Parameters
var active_spells:Array[Spell]
# These represent the Mana Resource that is spent when casting spells,
# and regenerates over time.
var mana_value_trackers:Array[ManaValueTracker]
var hp_bar : TextureProgressBar
# The path to go from overworld_hud to the Mana Value Tracker Objects.
const mana_tracker_path = "mana_hp_panelcontainer/HBoxContainer/mana_bars_vbox"
const hp_bar_path = "mana_hp_panelcontainer/HBoxContainer/hp_centercontainer"

# Shitty bandaid solution to stop newly-crafted spells from automatically casting.
# TODO Probably address this and make it less shitty
@onready var postcraft_cast_cd: Timer = $SpellcraftManager/spellcraft_cast_cd
var can_cast:bool = true 

var is_precasting:bool

#region Combat Parameters
var is_melee_ready:bool # for melee attack cooldown
@export var is_using_melee:bool = false # for melee attack animations. Exported to AnimationPlayer.
@export var basic_melee_damage:float
# Stuff like this will be MeleeCombatCount - the number of consecutive attacks the player
# can make. Also Melee Damage Bonus, etc.
#endregion

#endregion

#region Child Node References
# The Animation Player is used for any time-sensitive interactions, or anything
# that wants an inbuilt delay. For example, melee attacks and dying.
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var body_sprite: AnimatedSprite2D = $BodySprite

# NOTE: Overworld is index 0; Spellcraft is index 1; Pause is index 2
# TODO Clean this up in a way that removes the 'magic numbers' aspect.
@onready var player_hud: CanvasLayer = $PlayerHUD
@export var hud_manager : HudManager = player_hud as HudManager

@onready var scm: Node = %SpellcraftManager
@export var spellcrafter: SpellcraftManager = scm as SpellcraftManager
@onready var cast_origin: Marker2D = $BodySprite/cast_origin

# @onready var player_combat_entity: CombatEntity = %CombatEntity
@onready var melee_attack_cooldown: Timer = $BodySprite/melee_attack_hitbox/melee_attack_cooldown
#endregion

########################
## START OF FUNCTIONS ##
########################

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
	# player_combat_entity.health_bar_visual = hud_manager.overworld_hud.get_node(hp_bar_path+"/hp_bar") as TextureProgressBar
	
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
	#if(player_combat_entity.curr_health < player_combat_entity.max_health):
		#player_combat_entity.gain_health(player_combat_entity.health_regen_rate)

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
			MOVEMENT_STYLES.NORMAL:
				# Check for Sprint (TODO and Crouch) inputs
				# This will eventually be expanded for many movement categories
				if(Input.is_action_pressed("overworld_toggle_sprint")):
					current_speed = RUN_SPEED
				else:
					current_speed = BASE_SPEED
				# Handle jump.
				if Input.is_action_pressed("overworld_jump"):
					if(is_on_floor() || can_surface):
						velocity.y = JUMP_VELOCITY
				# Movement
				
			MOVEMENT_STYLES.SWIMMING:
				current_speed = SWIM_SPEED
				# Free Vertical Movement with slight gravity while underwater
				var dir_v := Input.get_axis("overworld_up", "overworld_down")
				if(dir_v != 0):
					velocity -= get_gravity() * delta * gravity_scale
					velocity.y = dir_v * current_speed
				else:
					velocity.y = get_gravity().y * delta * gravity_scale
				# Surfacing Controls
				if Input.is_action_pressed("overworld_jump") and can_surface:
					velocity.y = JUMP_VELOCITY
			MOVEMENT_STYLES.CLIMBING:
				# Free Vertical Movement with No Gravity. Gravity is already set to 0
				var dir_v := Input.get_axis("overworld_up", "overworld_down")
				velocity.y = dir_v * current_speed
			MOVEMENT_STYLES.FLYING:
				print("TODO Implement Flying")
				pass
		# Horizontal Deceleration: if not moving, reduce speed back to 0
		if direction:
			velocity.x = direction * current_speed
		else:
			velocity.x = move_toward(velocity.x, 0, current_speed)
			
	# Apply the MoveAndSlide regardless of whether the game is in Overworld
	# or Spellcraft, so that the player will continue falling due to gravity
	move_and_slide()
	#endregion
	
	# After moving, check for Spellcasting and Combat inputs:
	#region Spellcasting and Combat
	# TODO As with the Input Processing stuff, this can probably all be refactored,
	# and like assign a function to each input callback
	if(gsm.current_game_state == States.GAME_STATES.OVERWORLD):
		# If the player is precasting, they can either release a spell,
		# or launch a melee attack. Both of these will cancel the precast state
		if(is_melee_ready && Input.is_action_just_pressed("overworld_melee_attack")):
				basic_melee()
		
		# TODO Eventually change this to animation_player.play(spellcast)
		# and call cast_active_spell through that. Gonna be a headache trying
		# to fanagle the right parameters.
		## TODO Once I start implementing player progression, also need to check
		## If the player has unlocked this spell slot. Probably will be intrinsically managed
		## in the previous conditional & the spellcraft menu: if the slot isnt unlocked, it just
		## wont complete the craft step and therefore the spell will be null
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
	# This is a scale manipulation rather than a sprite.flip_h call
	# because the melee hitbox is childed to the sprite. The whole set needs
	# to be inverted in order for the hitboxes to be correct.
	if direction > 0:
		body_sprite.scale.x = 1
	elif direction < 0:
		body_sprite.scale.x = -1
		
	#Then determine animations
	if(gsm.current_game_state == States.GAME_STATES.SPELLCRAFTING):
		# If the player is in Spellcraft Mode, play a "Thinking" animation
		# and break out from _physics_process to ignore future animations
		# overwriting this.
		#print("TODO Play Thinking/Spellcrafting Animation")
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
			# Any swimming animations go here
			# Should basically always be playing so no need to toggle here.
			pass
		MOVEMENT_STYLES.CLIMBING:
			# Any climbing animations go here
			# Will need a way to play/pause based on whether the player is moving
			# Either Horizontally or Vertically
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

func set_movement_style(new_style:MOVEMENT_STYLES):
	current_movement_style = new_style
	# Kill all current velocity-altering effects
	# so gravity doesn't continue to affect the player's velocity during state changes
	# TODO this might be pretty jarring if you e.g. fall onto a ladder, maybe
	# try to lerp or tween to reduce the effect over about 0.2s
	velocity = Vector2.ZERO

func _on_spellcraft_cast_cd_timeout() -> void:
	can_cast = true

func precast_active_spell(spell_index:int):
	if(active_spells[spell_index] == null):
		print("No or Invalid spell in slot " + var_to_str(spell_index + 1))
	else:
		# TODO Play a "start-up" particle system and animation.
		# The animation will be tied to the player; the particles tied to the prefix.
		is_precasting = true
		active_spells[spell_index].precast_spell()

func cast_active_spell(spell_index:int):
	# TODO Turn off precast particles here.
	is_precasting = false
	# Fail check 1: Player doesn't have a spell in that spell slot
	if(active_spells[spell_index] == null):
		print("No or Invalid spell in slot " + var_to_str(spell_index + 1))
	else:
	# Fail Check 2: Player doesn't have enough mana to cast that spell.
		for m in mana_value_trackers:
			var i:int = m.get_index()
			if(m.current_mana < active_spells[spell_index].mana_cost[i]):
				print("Player does not have enough %s Mana to cast %s"%
				[SpellcraftManager.MANA_COLOURS.keys()[m.colour],active_spells[spell_index].spell_name])
				return
			# Mana Expenditure done while still in this for loop
			m.current_mana -= active_spells[spell_index].mana_cost[i]
		# Call that spell's Cast function - specific spell behaviours
		# are determined on a per-class basis
		active_spells[spell_index].cast_spell()

func basic_melee():
	is_precasting = false
	#print("TODO Basic Melee")
	animation_player.play("melee_attack_1")
	is_melee_ready = false
	melee_attack_cooldown.start()

func _on_melee_attack_cooldown_timeout() -> void:
	is_melee_ready = true
