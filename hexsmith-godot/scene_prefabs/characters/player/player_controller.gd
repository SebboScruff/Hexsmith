# The vast majority of direct input processing will be managed here, and then 
# various sub-effects will call functions in other places where necessary.

extends CharacterBody2D

# Movement Parameters
const SPEED = 150.0
const RUN_SPEED = 300.0
const CRAWL_SPEED = 75.0
var current_speed : float

const JUMP_VELOCITY = -400.0

# Child Node References
@onready var body_sprite: AnimatedSprite2D = $BodySprite

## START OF FUNCTIONS

# dont wanna see the nasty default cursor
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

func _input(event: InputEvent) -> void:
	## MENU INPUT CHECKS
	match(gsm.current_game_state):
		States.GAME_STATES.OVERWORLD:
			if(event.is_action_pressed("global_pause")):
				print("TODO Change to PAUSE Menu")
			elif(event.is_action_pressed("toggle_spellcraft_menu")):
				print("TODO Change to SPELLCRAFT Menu")
		
		States.GAME_STATES.SPELLCRAFTING:
			if(event.is_action_pressed("spellcraft_open_spellbook")):
				print("TODO Change to PAUSE Menu; Spellbook Tab")
			elif(event.is_action_pressed("toggle_spellcraft_menu")):
				print("TODO Return to Overworld")
		
		States.GAME_STATES.PAUSED:
			if(event.is_action_pressed("global_pause")):
				print("TODO Return to Overworld")
	## END OF MENU INPUT CHECKS

# All Movement and related animation work is done here
func _physics_process(delta: float) -> void:
	# If not in overworld, ignore all inputs
	# NOTE: gsm is the name of the Global GameStateManager scene
	if(gsm.current_game_state != States.GAME_STATES.OVERWORLD):
		pass

	## BEGINNING OF MOVEMENT INPUT PROCESSING: ##
	# Check for Sprint (TODO and Crouch) inputs
	# This will eventually be expanded for many movement categories
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
	
	
