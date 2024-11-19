# The vast majority of direct input processing will be managed here, and then 
# various sub-effects will call functions in other places where necessary.

extends CharacterBody2D

# Movement Parameters
const SPEED = 150.0
const RUN_SPEED = 300.0
const CRAWL_SPEED = 75.0
var current_speed : float

const JUMP_VELOCITY = -400.0

## CHILD NODE REFERENCES
@onready var body_sprite: AnimatedSprite2D = $BodySprite

# NOTE: Overworld is index 0; Spellcraft is index 1; Pause is index 2
# TODO Clean this up in a way that removes the 'magic numbers' aspect.
@onready var player_hud: CanvasLayer = $PlayerHUD
@export var hud_manager : HudManager = player_hud as HudManager

@onready var scm: Node = %SpellcraftManager
@export var spellcrafter: SpellcraftManager = scm as SpellcraftManager
## END OF CHILD NODE REFERENCES


## START OF FUNCTIONS

# dont wanna see the nasty default cursor
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

func _input(event: InputEvent) -> void:
	## MENU INPUT CHECKS
	match(gsm.current_game_state):
		States.GAME_STATES.OVERWORLD:
			if(event.is_action_pressed("global_pause")):
				gsm.change_game_state(States.GAME_STATES.PAUSED)
				hud_manager.change_active_menu(2)
			elif(event.is_action_pressed("toggle_spellcraft_menu")):
				gsm.change_game_state(States.GAME_STATES.SPELLCRAFTING)
				hud_manager.change_active_menu(1)
		
		States.GAME_STATES.SPELLCRAFTING:
			# Clear out the active mana selection before changing menus
			if(event.is_action_pressed("spellcraft_open_spellbook")):
				spellcrafter.clear_active_mana()
				gsm.change_game_state(States.GAME_STATES.PAUSED)
				# TODO Extend this to specifically open the pause menu ON the Spellbook tab
				hud_manager.change_active_menu(2)
			elif(event.is_action_pressed("toggle_spellcraft_menu")):
				spellcrafter.clear_active_mana()
				gsm.change_game_state(States.GAME_STATES.OVERWORLD)
				hud_manager.change_active_menu(0)
		
		States.GAME_STATES.PAUSED:
			if(event.is_action_pressed("global_pause")):
				gsm.change_game_state(States.GAME_STATES.OVERWORLD)
				hud_manager.change_active_menu(0)
	## END OF MENU INPUT CHECKS
	
	## SPELLCRAFT INPUT CHECKS ##
	# TODO Refactor to not be if-chain, this is horrible to look at
	if(gsm.current_game_state == States.GAME_STATES.SPELLCRAFTING):
		# Addition Hotkeys
		if(event.is_action_pressed("spellcraft_add_red")):
			spellcrafter.add_active_mana_instance(spellcrafter.MANA_COLOURS.RED)
		elif(event.is_action_pressed("spellcraft_add_blue")):
			spellcrafter.add_active_mana_instance(spellcrafter.MANA_COLOURS.BLUE)
		elif(event.is_action_pressed("spellcraft_add_green")):
			spellcrafter.add_active_mana_instance(spellcrafter.MANA_COLOURS.GREEN)
		elif(event.is_action_pressed("spellcraft_add_white")):
			spellcrafter.add_active_mana_instance(spellcrafter.MANA_COLOURS.WHITE)
		elif(event.is_action_pressed("spellcraft_add_black")):
			spellcrafter.add_active_mana_instance(spellcrafter.MANA_COLOURS.BLACK)
		elif(event.is_action_pressed("spellcraft_add_colorless")):
			spellcrafter.add_active_mana_instance(spellcrafter.MANA_COLOURS.COLOURLESS)
		# Removal Hotkeys
		elif(event.is_action_pressed("spellcraft_remove_mana")):
			spellcrafter.remove_last_instance()
		elif(event.is_action_pressed("spellcraft_clear_mana")):
			spellcrafter.clear_active_mana()
		# Assignment Hotkeys
		elif(event.is_action_pressed("spellcraft_bind_spellslot1")):
			spellcrafter.craft_and_bind(1)
		elif(event.is_action_pressed("spellcraft_bind_spellslot2")):
			print("TODO Craft and Bind to Hotkey 2")
		elif(event.is_action_pressed("spellcraft_bind_spellslot3")):
			print("TODO Craft and Bind to Hotkey 3")
		elif(event.is_action_pressed("spellcraft_bind_spellslot4")):
			print("TODO Craft and Bind to Hotkey 4")
		
	## END OF SPELLCRAFT INPUT CHECKS ##

# All Movement and related animation work is done here
func _physics_process(delta: float) -> void:
	# If not in overworld, ignore all inputs
	# NOTE: gsm is the name of the Global GameStateManager scene
	if(gsm.current_game_state != States.GAME_STATES.OVERWORLD):
		return

	## BEGINNING OF MOVEMENT INPUT PROCESSING: ##
	# Check for Sprint (TODO and Crouch) inputs
	# This will eventually be expanded for many movement categories
	# TODO Need to disable A/D Movement but maintain gravity/ vertical movement
	# While in Spellcraft
	if(Input.is_action_pressed("overworld_toggle_sprint")):
		current_speed = RUN_SPEED
	else:
		current_speed = SPEED
	
	var direction := Input.get_axis("overworld_move_left", "overworld_move_right")
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("overworld_jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	# Movement
	if direction:
		velocity.x = direction * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)

	move_and_slide()
	## END OF MOVEMENT INPUT PROCESSING ##
	## ---
	## BEGINNING OF SPRITE ANIMATION
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
	## END OF SPRITE ANIMATION
	## ---
	
	
