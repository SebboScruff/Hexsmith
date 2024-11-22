# The vast majority of direct input processing will be managed here, and then 
# various sub-effects will call functions in other places where necessary.
class_name Player
extends CharacterBody2D

#region Movement Parameters
const SPEED = 150.0
const RUN_SPEED = 300.0
const CRAWL_SPEED = 75.0
var current_speed : float

const JUMP_VELOCITY = -400.0
#endregion

#region Spellcraft Parameters
var active_spells: Array[Spell]
#endregion

#region Child Node References
@onready var body_sprite: AnimatedSprite2D = $BodySprite

# NOTE: Overworld is index 0; Spellcraft is index 1; Pause is index 2
# TODO Clean this up in a way that removes the 'magic numbers' aspect.
@onready var player_hud: CanvasLayer = $PlayerHUD
@export var hud_manager : HudManager = player_hud as HudManager

@onready var scm: Node = %SpellcraftManager
@export var spellcrafter: SpellcraftManager = scm as SpellcraftManager
#endregion

########################
## START OF FUNCTIONS ##
########################

# dont wanna see the nasty default cursor.
# NOTE The actual in-game visual cursor (for menu naviation and stuff) can be
# customised in Project Settings->General->Display->Mouse Cursor
func _ready() -> void:
	active_spells = [null, null, null, null]
	
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

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
		
		States.GAME_STATES.PAUSED:
			if(Input.is_action_just_pressed("global_pause")):
				gsm.change_game_state(States.GAME_STATES.OVERWORLD)
				hud_manager.change_active_menu(0)
#endregion

	# If paused, ignore all player-based physics processes.
	if(gsm.current_game_state == States.GAME_STATES.PAUSED):
		return
	
	# Gravity processing is the first thing to be checked, so that the player will still 
	# fall even if they are in the Spellcraft Menu
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# NOTE: Direction is declared outside of any conditionals because otherwise the animation code will break
	var direction := Input.get_axis("overworld_move_left", "overworld_move_right")

#region Overworld Controls
	#region Movement
	if(gsm.current_game_state == States.GAME_STATES.OVERWORLD):
		## BEGINNING OF MOVEMENT INPUT PROCESSING: ##
		# Check for Sprint (TODO and Crouch) inputs
		# This will eventually be expanded for many movement categories
		if(Input.is_action_pressed("overworld_toggle_sprint")):
			current_speed = RUN_SPEED
		else:
			current_speed = SPEED
		# Handle jump.
		if Input.is_action_just_pressed("overworld_jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY
		# Movement
		if direction:
			velocity.x = direction * current_speed
		else:
			velocity.x = move_toward(velocity.x, 0, current_speed)
			
	# Apply the MoveAndSlide regardless of whether the game is in Overworld
	# or Spellcraft
	move_and_slide()
	#endregion
	
	# After moving, check for Spellcasting and Combat inputs:
	#region Spellcasting and Combat
	# TODO As with the Input Processing stuff, this can probably all be refactored,
	# and like assign a function to each input callback
	# Also TODO This eventually wants to be broken down into precast() and cast()
	# stages to allow for some JUICE
	if(gsm.current_game_state == States.GAME_STATES.OVERWORLD):
		if(Input.is_action_just_pressed("overworld_melee_attack")):
			basic_melee()
		elif(Input.is_action_just_pressed("overworld_cast_spellslot1")):
			cast_active_spell(0)
		elif(Input.is_action_just_pressed("overworld_cast_spellslot2")):
			cast_active_spell(1)
		elif(Input.is_action_just_pressed("overworld_cast_spellslot3")):
			cast_active_spell(2)
		elif(Input.is_action_just_pressed("overworld_cast_spellslot4")):
			cast_active_spell(3)
	#endregion
#endregion

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
		elif(Input.is_action_just_pressed("spellcraft_bind_spellslot2")):
			spellcrafter.craft_and_bind(1)
		elif(Input.is_action_just_pressed("spellcraft_bind_spellslot3")):
			print("TODO Craft and Bind to Hotkey 3")
		elif(Input.is_action_just_pressed("spellcraft_bind_spellslot4")):
			print("TODO Craft and Bind to Hotkey 4")
		#endregion
#endregion

#region SPRITE ANIMATION
	# TODO Firstly, check if the player is in Spellcrafting Menu
	# If they are, play the "Thinking" animation and then return
	# to break out of _physics_process without doing further animation work
	
	# Flip depending on Movement Direction
	if direction > 0:
		body_sprite.flip_h = false
	elif direction < 0:
		body_sprite.flip_h = true
		
	#Then determine animations
	if is_on_floor():
		if direction == 0:
			body_sprite.play("idle")
		else:
			body_sprite.play("run")
	else:
		body_sprite.play("jump_whole")
#endregion SPRITE ANIMATION

func cast_active_spell(spell_index:int):
	if(active_spells[spell_index] == null):
		print("No or Invalid spell in slot " + var_to_str(spell_index + 1))
	
	## TODO Once we start implementing player progression, also need to check
	## If the player has unlocked this spell slot. Probably will be intrinsically managed
	## in the previous conditional & the spellcraft menu: if the slot isnt unlocked, it just
	## wont complete the craft step and therefore the spell will be null
	
	# Call that spell's Cast function - specific spell behaviours
	# are determined on a per-class basis
	active_spells[spell_index].cast_spell()

func basic_melee():
	print("TODO Basic Melee Attack")
